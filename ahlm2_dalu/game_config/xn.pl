#!/usr/bin/perl
#   help info please goto http://www.wanmei.com
#   name	The new package
#   version	nk2.0
#   email:	leenk@126.com
#   edit:	2012-12-18

use strict;
use Getopt::Long;
use Term::ANSIColor qw(:constants);
use XML::DOM;
use File::Basename;
use Time::Local;
#use MIME::Base64;
use Data::Dumper;
use Time::HiRes qw(time sleep);
use vars qw(%opt %g_opts $gameinstall $option $config $xml $xml_append $info $debug_password $iptables_restart $update_tomcat $kill $help $md5sum_files $CONFIG_FILE $XML_FILE $debug $iptables_restart1);
my $error =0;
%opt = (
	'gameinstall'      => \$gameinstall,
	'iptables_restart'  => \$iptables_restart,
	'update_tomcat'    => \$update_tomcat,
	'md5sum_files'     => \$md5sum_files,
	'kill'             => \$kill,
	'help'             => \$help,
	'option:s'         => \$option,
	'config:s'         => \$config,
	'xml:s'            => \$xml,
	'info:s'           => \$info,
	'debug_password:s' => \$debug_password,
	'a'                => \$xml_append,
);

####->输入输出,CONF文件,DATA文件编写
GetOptions(%opt);
my $do = &check_opt();
####->检查输入文件是否存在,或本地文件是否存在,不存在退出
&do_one();

####->脚本需要的一些信息
my $runinfo        = &get_runinfo();
my $package_config = &readConfig($CONFIG_FILE);
my $this_config    = &readDATA();

####->DATA_CONFIG,从文件尾获取信息,主要是一些配制,减少以后更改.
my $this_name      = basename($0);
my $this_dir       = $this_config->{'this_dir'};
my $this_version   = $this_config->{'this_version'};
my $win_destdir    = $this_config->{'win_destdir'};
my $db_destdir     = $this_config->{'db_destdir'};
my $name_destdir   = $this_config->{'name_destdir'};
my $srcdir         = $this_config->{'srcdir'};
my $realserver_dir = $this_config->{'realserver_dir'};
my $debug_log      = $this_config->{'debug_log'};

$debug = 1 if ( "$do->{'debug_password'}" eq "$this_config->{'debug_password'}" );    #当密码匹配时,可以启用debug模式

system("> $debug_log") if ($debug);
print "Start debug model !\n" if ($debug);

####->CONF_CONFIG,从类似 package.conf文件获取信息
my $files_md5_src           = $package_config->{'files_md5_src'};
my $files_md5_dest          = $package_config->{'files_md5_dest'};
my $game_project_dir        = $package_config->{'game_project_dir'};
my $Serveruser              = $package_config->{'Serveruser'};
my $tomcat_dir              = $package_config->{'tomcat_dir'};
my $tomcat_sdir             = $package_config->{'tomcat_sdir'};
my $config_example          = $package_config->{'config_example'};
my $ip_xml_conf_dir         = $package_config->{'ip_xml_conf_dir'};
my $ip_xml_index_servername = $package_config->{'ip_xml_index_servername'};
####->检查所有conf文件中录入的参数是否为空,是否匹配等,增加角本安全性.
####&check_conf();

####->environment准备
my $hostinfo   = &get_hostinfo($ip_xml_index_servername);    #eg: backup  建立ip相关的关联数组,全局引用 反回$hostinfo 的xmlname值.
my $packagedir = "$this_dir/$game_project_dir";              #eg:/export/update/sgpackage
chdir("$packagedir/");

my $default_xmldir  = "$packagedir/config/";                      #config可以放到conf文件中
#my $default_xmldir;                      #config可以放到conf文件中
my $default_xmlfile = $default_xmldir . $hostinfo->{'xmlname'};
my $LOGDIR          = &touch_user_log;
####->上以部分总结.
####->1.完成了所有输入的检查.
####->2.完成配制文件的检查.
####->3.完成配制文件中指定的配制文件的检查.
####->4.得到的应该都是信息.未有操作内容.
####->-----------------------------------------------主逻辑开始--------------------------

####->创建xml相关对像
my ( $doc, $doc_new );
if ( defined $do->{'xml'} ) {
	$doc     = open_xml($default_xmlfile);
	$doc_new = open_xml( $do->{'xml'} );
}
else {
	$doc = open_xml($default_xmlfile);
}

####->处理合并xml ,debug模式会打印

$doc = do_two( $doc, $debug, $doc_new );



####->获取xml主要对像,不重复
my $configure  = $doc->getElementsByTagName('configure')->item(0);
my $xmltree    = $configure->getElementsByTagName('xmltree')->item(0);
my $data_index = $configure->getElementsByTagName('data_index')->item(0);
my $group      = $configure->getElementsByTagName('group')->item(0);

####->得到xml执行数内容,eg:   gameinstall=game,tomcat,iptables
my $branch = $xmltree->getAttribute('branch');
my @BRANCH = split( /;/, $branch );
my %option_tree;
foreach (@BRANCH) {
	if ( $_ =~ /^([a-zA-Z0-9-_]*)=([a-zA-Z0-9,]*)$/ ) {
		$option_tree{$1} = $2;
	}
	else {
		print 'no key value' . " $_\n";    #print_help
	}
}



####->获取各服务器可管理信息,但不做判断,因为有些服务器可能是没有用的.
my $my_manager = &get_manager_fromxml($group);

=head1
while ( my ($k,$v) = each %$my_manager ){ 
print "$k ==> ".$my_manager->{$k}->{'group'}."\n"; 
}
=cut

####->创建执行顺序数组,option_tree级别大循环 eg:game tomcat iptables
my @dom_order;
while ( my ( $k, $v ) = each %option_tree ) {
	foreach ( split( /,/, $v ) ) {
		if ( my $dd = $configure->getElementsByTagName($_)->item(0) ) {
			my @option_xmlparser = [ $k, $dd ];
			push( @dom_order, [@option_xmlparser] ) if ( $k eq $do->{'option'} );
		}
		else {
			die "$_ need xml structure";
		}
	}
}
####->对option与xmltree中的定义做匹配检查.
if( exists $option_tree{$do->{'option'}} ){
	print_chang('Package option is start.');
}else{
	print_chang($do->{'option'}.' is ERROR!!!! ');
	die " $do->{'option'} xml 未定义\n";
}

####->创建中循环关系,解析例如game对象,按顺序自上而下执行我个操作,first_doshell,copy,delete......

foreach (@dom_order) {    #print_xml $_->[0][1];
	if ( exists $option_tree{$_->[0][0]} ){
		do_three( $_->[0][0], $_->[0][1],$my_manager );    ##00 操作名字,01操作对像,筛选分类不同的方法去实现
	}else{
		die "please check xmltree, ".$_->[0][0]." =?\n";
	}
}
print_chang();

#+++++++++++++++++++++++++++++++++++++++++++++++++++主逻辑结束+++++++++++++++++++++++++++++++++++++++++
####->程序初始化所需方法集
sub check_conf {    #正式版完成
	die "Please check package.conf {files_md5_src}"    unless $files_md5_src;
	die "Please check package.conf {files_md5_dest}"   unless $files_md5_dest;
	die "Please check package.conf {game_project_dir}" unless $game_project_dir;    #后期要进行目录判断
	die "Please check package.conf {Serveruser}"       unless $Serveruser;
	die "Please check package.conf {tomcat_dir}"       unless $tomcat_dir;          #后期要进行目录判断
	die "Please check package.conf {tomcat_sdir}"      unless $tomcat_sdir;         #后期要进行目录判断
	die "Please check package.conf {ip_xml_conf_dir}"  unless $ip_xml_conf_dir;     #后期要进行目录判断
}

sub check_opt {
	#test ok
	&print_help( 0, '' ) if ( defined $help );
	my %p;
	my $option_number = 0;
	if ( defined $config ) {
		$p{'config'} = $config;
	}
	else {
		$p{'config'} = undef;    #以后此处为配制文件地址
	}
	if ( defined $xml ) {
		$p{'xml'} = $xml;
	}
	else {
		$p{'xml'} = undef;       #以后此处为配制文件地址
	}
	if ( defined $xml_append ) {
		$p{'append'} = 1;
		print_help( '100', 'xml追加与,xml文件指定要同时使用,后边换成英文' ) unless ( $p{'xml'} );
	}
	else {
		$p{'append'} = 0;
	}
	if ( defined $debug_password ) {
		$p{'debug_password'} = $debug_password;
	}
	else {
		$p{'debug_password'} = undef;    #以后此处为配制文件地址
	}
	if ( defined $info ) {
		$p{'info'} = $info;
	}
	else {
		$p{'info'} = undef;              #以后此处为配制文件地址
	}
	if ( defined $gameinstall ) {
		$p{'option'} = 'gameinstall';
		( $option_number++ );
	}
	if ( defined $update_tomcat ) {
		$p{'option'} = 'update_tomcat';
		( $option_number++ );
	}
	if ( defined $kill ) {
		$p{'option'} = 'kill';
		( $option_number++ );
	}
	if ( defined $iptables_restart ) {
		$p{'option'} = 'iptables_restart';
		( $option_number++ );
	}
	if ( defined $md5sum_files ) {
		$p{'option'} = 'md5sum_files';
		( $option_number++ );
	}
	if ( defined $option ) {
		$p{'option'} = $option;
		$p{'other'}  = 1;
		( $option_number++ );
	}
	#print "-----------$option_number -------------\n";
	if ( $option_number eq 1 ) {
		return \%p;
	}
	elsif ( $option_number gt 1 ) {
		&print_help( '2', '' );    #2需要打的就是需要操作命令
	}
	else {
		&print_help( 1, "Please check input args! eg: --gameinstall or --help\n" );
	}
}

sub get_runinfo {
	my %r = ();
	$r{'user'}       = qx|whoami|;
	$r{'start_time'} = get_localtime();
	$r{'dir'}	= dirname($0); 
	$r{'name'}	= basename($0);
	$r{'TERM'}	= $ENV{'TERM'}; 
	#	$r{'over_time'} = get_localtime();
	#	$r{'eroor_number'} = qx|whoami|;
	$r{'ARGV'} = \@ARGV;
	return \%r;
}

sub readConfig() {
	my $file   = shift;
	my %config = ();
	open( CONFIGCONF, "<", $file ) or die "Error: open file: $file error!\n $!\n";
	print "readConfig Reading config file: $file.\n";
	while (<CONFIGCONF>) {
		chomp();
		next if (/^\s+#/);
		next if (/^#/);
		next if (/^\/s*$/);
		$_ =~ s/ = /=/g;
		my ( $key, $value ) = split q{=}, $_;
		$config{$key} = $value;
	}
	close(CONFIGCONF);
	return \%config;
}

sub readDATA() {
	my %config;

	my $string = 'this_dir = /home/super/update/ahlm2package
this_version = NK_2.0
srcdir = 
win_destdir = /cygdrive/d/server
db_destdir = /export
name_destdir = /export/server
realserver_dir = srcfiles/real_server
ip_xml_conf_dir = ip_xml.conf
debug_log = /dev/null
debug_password = goodgirl';
	my @dd = split(/\n/,$string);
	#while (<DATA>) {
	foreach (@dd) {
		chomp();
		next if (/^\s+#/);
		next if (/^#/);
		next if (/^\/s*$/);
		$_ =~ s/ = /=/g;
		my ( $key, $value ) = split q{=}, $_;
		$config{$key} = $value;
	}
	return \%config;
}

sub get_hostinfo {
        
	#my ($hostname) = @_;                ## 对应package.conf ip_xml_index_server
	my ($hostname) = qx/hostname/;       ## 取消 package.conf ip_xml_index_server
	chomp $hostname;
        my %hostinfo;
        $hostinfo{'ipaddr'}=`cat /etc/hosts |grep -w $hostname  |awk '{print \$1}'`;
        chomp($hostinfo{'ipaddr'});
        my $ipxmlconf = './ipxml.conf';
	$ipxmlconf = $package_config->{'ip_xml_conf_dir'} if ( $package_config->{'ip_xml_conf_dir'} );
	if ( $ipxmlconf =~ m/^\.\/(.*)/ ){
		open XMLFILE, "$runinfo->{'dir'}/$1" or die;
	}else{
		open XMLFILE, "< $ipxmlconf" or die ;
	}
        
        my @array1 = <XMLFILE>;
	close(XMLFILE);
	my ( $xmlfile_tmp, $j ) = ();

	foreach (@array1) {
		next if ( $_ =~ /^#/ );
		my @array2 = split( /[\s\t]+/, $_ );
		if ( $array2[0] eq $hostinfo{'ipaddr'} ) {
			$j += 1;
			$xmlfile_tmp = $array2[1];
		}
	}
        
	if ( $j eq 1 ) {
		$hostinfo{'xmlname'} = $xmlfile_tmp;
	}
	else {
		#print $j."\n";
		print BOLD, RED, "please check your ipxml.conf,there are some ipaddress that the same in this file.\n", RESET;
		exit 1;
	}
	#所有以本机ip为引的事件都有本模块返回
	return \%hostinfo;
        print $xmlfile_tmp;
}

sub touch_user_log {
	my ( $sec, $min, $hour, $mday, $mon, $year ) = localtime();
	$mon  += 1;
	$mon = '0'.$mon if ($mon < 10);
	$year += 1900;
	my $time     = "$year$mon$mday\_$hour$min$sec";
	#my $time     = "$year-$mon-$mday\_$hour:$min:$sec";
	my $time_tar = "$year$mon$mday\_$hour$min$sec";
	mkdir("$this_dir/$game_project_dir/log/");
	mkdir("$this_dir/$game_project_dir/log/$time");
	open UL, "> $this_dir/$game_project_dir/log/$time/all.log";
	close UL;
	return "$this_dir/$game_project_dir/log/$time";
}

sub open_xml {
	my ($xmlfile) = @_;
	my $doc = eval {
		my $xmlparser = new XML::DOM::Parser;
		my $t         = $xmlparser->parsefile($xmlfile);
		print "$t\n";
                return $t;
	};
	if ($doc) {
		return $doc;
	}
	else {
		die "$xmlfile xml is error";    #后期用print_help
	}
	return $doc;
}

sub get_manager_fromxml {
	my ($xml_object) = @_;
	my $host = $xml_object->getElementsByTagName('host')->item('0');    #->getAttribute('HOSTNAME');
	my %hash;
	for ( $xml_object->getChildNodes ) {
		next if ( ( $_->getNodeName ) =~ /^#/ or ( $_->getNodeName ) !~ /^host$/ );
		my $hostname    = $_->getAttribute('HOSTNAME');
		my $group       = $_->getAttribute('group');
		my $osinfo      = $_->getAttribute('osinfo');
		my $manager_opt = $_->getAttribute('manager_opt');
####->rootoption need { $user = > root };
		my $user        = $_->getAttribute('user');
		my $ipaddrnum   = $_->getElementsByTagName('ifcfg')->getLength;
		my $ipaddress;

		if ( $ipaddrnum lt 0 ) {
			$ipaddress = $_->getElementsByTagName('ifcfg')->item( $ipaddrnum - 1 )->getAttribute('ipaddr');
		}
		else {
			$ipaddress = undef;
		}
		#		my $ipaddress_host	= join('.',unpack('C4',$addrs[0]));
		$hash{$hostname} = ( { group => $group, osinfo => $osinfo, manager_opt => $manager_opt, user => $user, ipaddr => $ipaddress} );
	}
	return \%hash;
}

####->do_one所需所有方法集  ------------------------------------------------------------------------------
####->do_one
sub do_one {    #后期细化,要多查文件都在不在.现在缺少原始xml的检查.

	####->查config文件
	if ( defined $do->{'config'} ) {
		( -e $do->{'config'} ) or die "Error: $do->{'config'} no exist!\n";
		( -r $do->{'config'} ) or die "Error: $do->{'config'} Cannot read it!\n";
		$CONFIG_FILE = $do->{'config'};
	}
	else {
		$CONFIG_FILE = dirname($0) . '/package.conf';
		( -e $CONFIG_FILE ) or die "Error: $CONFIG_FILE no exist!\n";
		( -r $CONFIG_FILE ) or die "Error: $CONFIG_FILE Cannot read it!\n";
	}

	####->查xml文件
	if ( defined $do->{'xml'} ) {
		( -e $do->{'xml'} ) or die "Error: $do->{'xml'} no exist!\n";
		( -r $do->{'xml'} ) or die "Error: $do->{'xml'} Cannot read it!\n";
	}

	if ( defined $do->{'xml_append'} ) {
		$CONFIG_FILE = dirname($0) . '/package.conf';
		( -e $CONFIG_FILE ) or die "Error: $CONFIG_FILE no exist!\n";
		( -r $CONFIG_FILE ) or die "Error: $CONFIG_FILE Cannot read it!\n";
	}
}
####->do_one over

####->do_two所需所有方法集  ------------------------------------------------------------------------------OK
sub do_two {    #ok
	my ( $doc, $debug, $doc_new ) = @_;
	my $lastdoc;
	if ($xml) {    #指定了文件了
		if ( $do->{'append'} ) {
			#追加操作
			$lastdoc = &merge_xml( $doc, $doc_new );
		}
		else {
			#替换操作,如替换xml中无data_index group从原xml取.如有data_index group 完全替换.
			$lastdoc = &repleace_xml( $doc, $doc_new );
		}
	}
	else {
		$lastdoc = $doc;
	}

	$lastdoc = replace_data_index($lastdoc);
	####->这个地方需要加入xmltree的检查．如没有就默认　gameinstall = game + tomcat ;iptables = iptables;
	$lastdoc->printToFile('lastinfo.xml')                                                                                             if $debug;
	print "------------------------------------------------  print xml start -------------------------------------------------\n\n\n" if $debug;
	system("xmllint --format lastinfo.xml")                                                                                           if $debug;
	print "------------------------------------------------  print xml over --------------------------------------------------\n\n\n" if $debug;
	return $lastdoc;
}

sub replace_data_index {
	my ($xmlparser) = @_;
	my %index;
	my $string = $xmlparser->toString;
	$data_index = $xmlparser->getFirstChild->getElementsByTagName('data_index')->item('0');
	 foreach ( my @new_index = $data_index->getChildNodes ) {
		my $node = $_;
		if ( ( my $NodeName = $_->getNodeName ) !~ /^#/ ) {
			if ( $NodeName =~ m/info/){
				my $key = $node->getAttribute('key');
				my $value = $node->getAttribute('value');
				$index{$key} = $value;				#覆盖之前的值
			}
		}
	}
	while( my ($k,$v) = each %index ){
		$string =~ s/##$k##/$v/g
	}
	my $lastdoc = eval {
                my $xmlparser = new XML::DOM::Parser;
                my $t         = $xmlparser->parse($string);
                return $t;
        };
	if ($lastdoc) {
		return $lastdoc;
        }
        else {
                die "$string xml is error";    #后期用print_help
        }
}

sub repleace_xml {
	#这个方法把老xml中的节点内容做替换
	my ( $old, $new ) = @_;
	my ( $o, $n );
	if ( ( $o = $old->getFirstChild )->getNodeName !~ /configure/ ) {
		die 'old xml is error ,no find out configure' . "\n";
	}
	if ( ( $n = $new->getFirstChild )->getNodeName !~ /configure/ ) {
		die 'new xml is error ,no find out configure' . "\n";
	}
	foreach ( my @new_index = $n->getChildNodes ) {
		if ( ( my $NodeName = $_->getNodeName ) !~ /^#/ ) {
			my $o_tmp = $o->getElementsByTagName($NodeName)->item('0');
			my $n_tmp = $n->getElementsByTagName($NodeName)->item('0');
			$n_tmp->setOwnerDocument($old);
			if ($o_tmp) {
				$o->replaceChild( $n_tmp, $o_tmp );
			}
			else {
				$o->appendChild($n_tmp);
			}
		}
	}
	return $old;
}

sub merge_xml {

	#未用递归,可以用,不判断configure时直接用最好
	#这个方法只把新xml合并到现有xml的configure段.如果有同名的.就新生成结点
	#后期是否改变xmltree的值,还有是否可新增或替换现有  repleace_index.
	#xml root 结点为 configure
	my ( $old, $new ) = @_;
	my ( $o, $n );
	if ( ( $o = $old->getFirstChild )->getNodeName !~ /configure/ ) {
		die 'old xml is error ,no find out configure' . "\n";
	}
	if ( ( $n = $new->getFirstChild )->getNodeName !~ /configure/ ) {
		die 'new xml is error ,no find out configure' . "\n";
	}

	foreach ( my @new_index = $n->getChildNodes ) {

		#foreach (@new_index) {
		if ( ( my $NodeName = $_->getNodeName ) !~ /^#/ and $_->getNodeName !~ /group/ ) {
			my $o_tmp = $o->getElementsByTagName($NodeName)->item('0');
			my $n_tmp = $n->getElementsByTagName($NodeName)->item('0');
			if ($o_tmp) {
				#
				foreach ( my @Node2Name_index = $n_tmp->getChildNodes ) {
					if ( ( my $Node2Name = $_->getNodeName ) !~ /^#/ ) {
						my $o_2 = $o_tmp->getElementsByTagName($Node2Name)->item('0');
						my $n_2 = $n_tmp->getElementsByTagName($Node2Name)->item('0');
						if ($o_2) {
							foreach ( my @Node3Name_index = $n_2->getChildNodes ) {
								if ( ( my $Node3Name = $_->getNodeName ) !~ /^#/ ) {
									my $n_3 = $n_2->getElementsByTagName($Node3Name)->item('0');
									$n_3->setOwnerDocument($old);
									$o_2->appendChild($n_3);
								}
							}
						}
						else {
							$n_2->setOwnerDocument($old);
							$o_tmp->appendChild($n_2);
						}
					}
				}
			}
			else {
				$n_tmp->setOwnerDocument($old);
				$o->appendChild($n_tmp);
			}
		}
	}
	return $old;
}
####->do_over

####->do_three所需所有方法集------------------------------------------------------------------------------
sub do_three {
	my ( $option_name, $xmlparser,$my_manager ) = @_;
	print_chang('');
	print_chang($option_name.' =>'.$xmlparser->getNodeName);

	if ( my $k = $xmlparser->getElementsByTagName('init_touchfile')->item(0) ) {
		print_chang($option_name.' =>'.$xmlparser->getNodeName.'=>touchfile_init');
		do_init_touch_xmlparser($k);
		print_xml($k) if $debug;
	}
	if ( my $k = $xmlparser->getElementsByTagName('first_do_shell')->item(0) ) {
		print_chang($option_name.' =>'.$xmlparser->getNodeName.'=>first_do_shell');
		do_shell_xmlparser ($k,$my_manager);
		print_xml($k) if $debug;
	}
	if ( my $k = $xmlparser->getElementsByTagName('copy')->item(0) ) {
		print_chang($option_name.' =>'.$xmlparser->getNodeName.'=>copy');
		do_copy_xmlparser($k);
		print_xml($k) if $debug;
	}
	if ( my $k = $xmlparser->getElementsByTagName('delete')->item(0) ) {
		print_chang($option_name.' =>'.$xmlparser->getNodeName.'=>delete');
		do_delete_xmlparser($k);
		print_xml($k) if $debug;
	}
	if ( my $k = $xmlparser->getElementsByTagName('touchfile')->item(0) ) {
		print_chang($option_name.' =>'.$xmlparser->getNodeName.'=>touchfile');
		do_touch_xmlparser($k);
		print_xml($k) if $debug;
	}
	if ( my $k = $xmlparser->getElementsByTagName('replace_all')->item(0) ) {
		print_chang($option_name.' =>'.$xmlparser->getNodeName.'=>replace');
		do_replace_xmlparser($k,$LOGDIR);
		print_xml($k) if $debug;
	}

	if ( my $k = $xmlparser->getElementsByTagName('last_do_shell')->item(0) ) {
		print_chang($option_name.' =>'.$xmlparser->getNodeName.'=>last_do_shell');
		do_shell_xmlparser ($k,$my_manager);
		print_xml($k) if $debug;
	}

}

###->锁定源目录,未锁定目标地址
sub do_copy_xmlparser {
	my ($copy) = @_;
	unless ( -d "$realserver_dir" ) {
		system("mkdir -p $realserver_dir");
	}
	else {
		system("rm -rf $realserver_dir/*");
	}
	my $cp    = $copy->getElementsByTagName('cp');
	my $cpnum = $cp->getLength;
	if ( $cpnum > 0 ) {
		for ( my $i = 0 ; $i < $cpnum ; $i++ ) {
			my $sfile      = $copy->getElementsByTagName('cp')->item($i)->getAttribute('sfile');
			my $dfile      = $copy->getElementsByTagName('cp')->item($i)->getAttribute('dfile');
			my $cpsrcfile  = "$sfile";
			my $cpdestfile = "$dfile";
			copy_perl( $cpsrcfile, $cpdestfile );
		}
	}
	system("/bin/chmod -R 755 $realserver_dir");
}

sub copy_perl {    #老方法重用,ok
	my ( $cpsrcfile, $cpdestfile ) = @_;
	tprint( "copyneirong", $cpsrcfile, $cpdestfile );

	#copy
	if ( -e $cpsrcfile ) {
		my $tmpcpdestfile;
		tprint("$cpsrcfile -------------------chunzai");
		if ( -d $cpsrcfile and ( -d $cpdestfile or -e $cpdestfile ) ) {
			tprint("$cpsrcfile is d,$cpdestfile is d or -e $cpdestfile -f");
			if ( $cpdestfile =~ m@\/\$@ ) {
				system("/bin/mkdir -p $cpdestfile");
				system("/bin/cp -arf $cpsrcfile $cpdestfile/");
				tprint("/bin/cp -arf $cpsrcfile $cpdestfile/");
				tprint("dir->dir/");

				#		dir->dir/;
			}
			else {
				system("/bin/mkdir -p $cpdestfile");
				system("/bin/cp -arf $cpsrcfile/* $cpdestfile/");
				tprint("/bin/cp -arf $cpsrcfile/* $cpdestfile/");

				#		dir->dir;
			}
		}
		elsif ( -f $cpsrcfile and -f $cpdestfile ) {
			tprint("$cpsrcfile is f,$cpdestfile is f");
			$tmpcpdestfile = dirname($cpdestfile);
			system("/bin/mkdir -p $tmpcpdestfile");
			system("/bin/cp -af $cpsrcfile $cpdestfile");
			tprint("/bin/cp -af $cpsrcfile $cpdestfile");
			tprint("file->file");

			#	file->file;
		}
		elsif ( -f $cpsrcfile and -d $cpdestfile ) {
			tprint("$cpsrcfile is f,$cpdestfile is d");
			system("mkdir -p $cpdestfile");
			system("/bin/cp -af $cpsrcfile $cpdestfile/");

			#	file->dir;
		}
		elsif ( -d $cpsrcfile and -f $cpdestfile ) {
			tprint("$cpsrcfile is d,$cpdestfile is f");
			$tmpcpdestfile = dirname($cpdestfile);
			system("rm -f $cpdestfile");
			system("mkdir -p $tmpcpdestfile");
			system("/bin/cp -arf $cpsrcfile $tmpcpdestfile");
			tprint("/bin/cp -arf $cpsrcfile $tmpcpdestfile");
			tprint("file->dir");

			#	dir->file;   #xml err
		}
		else {
			#copy over
			$tmpcpdestfile = dirname($cpdestfile);
			system("rm -f $cpdestfile");
			system("mkdir -p $tmpcpdestfile");
			system("/bin/cp -arf $cpsrcfile $cpdestfile");
			tprint("/bin/cp -arf $cpsrcfile $cpdestfile");

			#	all->null;
		}
	}
	else {
		tprint("$cpsrcfile is not exist");
	}

}

sub do_delete_xmlparser {    #ok
	my ($delete) = @_;
	my $del      = $delete->getElementsByTagName('del');
	my $delnum   = $del->getLength;
	if ( $delnum > 0 ) {
		for ( my $i = 0 ; $i < $delnum ; $i++ ) {
			my $deletefile = $del->item($i)->getAttribute('file');
			system("rm -rf $deletefile");
		}
	}
}

sub do_onemd5 {              #f未确定x效验方法
	my $md5sum = $this_config->{'files_md5file'};
        ( -e $md5sum ) or die "Error: $md5sum no exist!\n";
        ( -r $md5sum ) or die "Error: $md5sum Cannot read it!\n";	
	open MD5FILE, "<$md5sum" or die 'No such file '.$md5sum;
	my @firstmd5 = <MD5FILE>;
	close MD5FILE;
	open ECHOMD5, "> $md5sum.new";
	for ( my $l = 0 ; $l < @firstmd5 ; $l++ ) {
		my $tmpname = s/$files_md5_src/$files_md5_dest/;
		print ECHOMD5 "$tmpname";
	}
	close ECHOMD5;
	my $md5check = `md5sum -c $md5sum.md5 2>&1 |grep -c -v OK`;
	if ( $md5check != 0 ) {
		print "Please check $md5sum\n";
		exit 1;
	}
}


sub do_shell_xmlparser {
	my ($t_do_shell,$server_ref) = @_;
	my $ds		= $t_do_shell->getElementsByTagName('ds');
	my $dsnum	= $ds->getLength;
	if ( $dsnum > 0 ) {
		for ( my $i = 0 ; $i < $dsnum ; $i++ ) {
			my $servername	= $ds->item($i)->getAttribute('servername');
			my $do_shell	= $ds->item($i)->getAttribute('do_shell');
			my $user = $server_ref->{$servername}->{'user'};
			my $ssh_key;
			if ( $this_config->{$user.'_ssh_key'} ){
				$ssh_key = " -i ".$this_config->{$user.'_ssh_key'};
			}
			my $manager_opt= $server_ref->{$servername}->{'manager_opt'};
			if( $manager_opt =~ m/bash/i){
				system("$do_shell");
				$error++ if($?);
			}
			elsif( $manager_opt =~ m/ssh-([0-9]*)/i ){
				system( "ssh -p $1 $ssh_key $user\@$servername \"$do_shell\"" );
				$error++ if($?);
			}
			elsif ( $manager_opt =~ m/^ssh$/i ){
				system("ssh -p 22 $ssh_key $user\@$servername \"$do_shell\"");
				$error++ if($?);
			}
			elsif ( $manager_opt =~ m/^rsh$/i ) {
				system("rsh $servername \"$do_shell\"");
				$error++ if($?);
			}
			
			elsif ( $manager_opt =~ m/^xn$/i ) {
				system("$do_shell");
				$error++ if($?);
			}
                        
                        else{
				print "$servername $manager_opt 没有定制方法\n";    											#双打印
			}
			print_chang($i);
		}
	}
}

sub do_touch_xmlparser {
	my ($touchfile) = @_;

	#cat -A /etc/sudoers |grep '"' |sed s/\\$/n/g   是否改成兼容双引号和单引号#
	#cat -A /etc/sudoers |sed 's/\$$/\\n/g'#
	my $tf    = $touchfile->getElementsByTagName('tf');
	my $tfnum = $tf->getLength;
	if ( $tfnum > 0 ) {
		for ( my $i = 0 ; $i < $tfnum ; $i++ ) {
			tprint( $touchfile->getElementsByTagName('tf')->item('0')->getAttribute('file') );
			my $tf_xml  = $touchfile->getElementsByTagName('tf')->item($i);
			my $file    = $tf_xml->getAttribute('file');
			my $file_bk    = $tf_xml->getAttribute('file_bk');
			my $owner   = $tf_xml->getAttribute('owner');
			my $chmod   = $tf_xml->getAttribute('chmod');
			my $content = $tf_xml->getAttribute('content');
			if ( dirname($file) and -f $file ) {
				system("cp   $file $file_bk") if $file_bk;
				system("diff $file $file_bk") if $file_bk;
				system("chown $owner $file") if $owner;
				system("chown $owner $file") if $owner;
				system("chmod $chmod $file") if $chmod;
				system("echo -e \"$content\" | sed 's/^ //g' > $file"); #or print "touch file is error";    ###->english
			}
			else {
				system("touch $file");
				system("cp   $file $file_bk") if $file_bk;
				system("diff $file $file_bk") if $file_bk;
				system("chown $owner $file") if $owner;
				system("chmod $chmod $file") if $chmod;
				system("echo -e \"$content\" | sed 's/^ //g' > $file");
			}
		}
	}
}


sub do_init_touch_xmlparser {
	my ($touchfile) = @_;

	#cat -A /etc/sudoers |grep '"' |sed s/\\$/n/g   是否改成兼容双引号和单引号#
	#cat -A /etc/sudoers |sed 's/\$$/\\n/g'#
	my $tf    = $touchfile->getElementsByTagName('tf');
	my $tfnum = $tf->getLength;
	if ( $tfnum > 0 ) {
		for ( my $i = 0 ; $i < $tfnum ; $i++ ) {
			tprint( $touchfile->getElementsByTagName('tf')->item('0')->getAttribute('file') );
			my $tf_xml  = $touchfile->getElementsByTagName('tf')->item($i);
			my $file    = $tf_xml->getAttribute('file');
			my $file_bk    = $tf_xml->getAttribute('file_bk');
			my $owner   = $tf_xml->getAttribute('owner');
			my $chmod   = $tf_xml->getAttribute('chmod');
			my $content = $tf_xml->getAttribute('content');
			if ( dirname($file) and -f $file ) {
				system("chown $owner $file") if $owner;
				system("chmod $chmod $file") if $chmod;
				system("echo -e \"$content\" | sed 's/^ //g' > $file"); #or print "touch file is error";    ###->english
                                my $flag = system("diff $file $file_bk ") if $file_bk;
                                if ($flag){print  BOLD RED "1 check gs.conf.m4\n" ,RESET; exit};
                                system ("cp $file $file_bk");
			}
			else {
				system("touch $file");
				system("chown $owner $file") if $owner;
				system("chmod $chmod $file") if $chmod;
				system("echo -e \"$content\" | sed 's/^ //g' > $file");
                                my $flag = system("diff $file $file_bk ") if $file_bk;
                                if ($flag){print BOLD RED "2 check gs.conf.m4\n" ,RESET; exit};
                                system ("cp $file $file_bk");
			}
		}
	}
}



sub write_user_log {                                                                                     #未完成
	my ( $file, $info ) = @_;
	#建立句柄,多次复用,用于业务系统展示,无法写入存入数组,最后写入文件

}

sub do_replace {                                                                                         #老方法重用,ok
	my ( $src, $dest, $line ) = @_;
	my @result;
	if ( $line =~ s/$src/$dest/g ) {
		$result[1] = 1;
	}
	else {
		$result[1] = 0;
	}
	$result[0] = $line;
	return @result;
}

sub do_replace_xmlparser {
	my ($replace_all,$LOGDIR) = @_;
	open REP_LOG, ">> $LOGDIR/replace_err.log";
	my $replaces = $replace_all->getElementsByTagName('replace');
	my $replace_num = $replaces->getLength;
	if($replace_num>0){
		for ( my $n = 0 ; $n < $replace_num ; $n++ ){
			my $replace = $replaces->item($n);
			my $file    = $replace->getAttribute('file');
			my $descs   = $replace->getElementsByTagName('desc');
			if ( -f $file){
				open REP_FILE, "< $file";
				my @array_line = <REP_FILE>;
				close(REP_FILE);
				open RW, "> $file";
				for ( my $j = 0 ; $j < @array_line ; $j++ ) {
					chomp( $array_line[$j] );
					my @result;
					my $line_ing;
					my $line_input;
					my $num = 0;
					for ( my $k = 0 ; $k < $descs->getLength ; $k++ ) {
						my $desc = $descs->item($k);
						my $src  = $desc->getAttribute('src');
						my $dest = $desc->getAttribute('dest');
						if ( $num eq 1 ) {
							$line_input = $line_ing;
						}
						else {
							$line_input = $array_line[$j];
						}
						@result = &do_replace( $src, $dest, $line_input );
						if ( $result[1] eq 1 ) {
							$line_ing = $result[0];
							$num      = 1;
							next;
						}
					}
					print RW	"$result[0]\n";
				}
				close(RW);
			}
			else {
				print REP_LOG "$file is not exist.\n";
			}
		}
		close(REP_LOG);
	}
}

####->共用方法集  ------------------------------------------------------------------------------
sub print_chang { 
	my ($a) = @_;
	my $length = 90;
	my $al = length($a);
	my $dl = ( $length - $al -3);
	print '<';
	my $tl = 0;
	do {
	   print ' ';
	   $tl++;
	}while ( $tl < 3 );
	if ( $runinfo->{TERM} =~ m/linux/i or $runinfo->{TERM} =~ m/xterm/i ){ 
		print BOLD YELLOW," | $_[0]  ",RESET;
	}else{
		print " | $_[0]  ";
	}
	$tl = 0;
	do {
	   print ' ';
	   $tl++;
	}while ( $tl < $dl );
	print ">\n";
}

sub print_help {
	# test ok
	#	&print_help('1','-o需要跟操作');
	my ( $status, $info ) = @_;
	my $help_info = 'Usage: Opackage [OPTION]...
Do xml operation.
Config file is package.conf and xml file.
Operation :fist_do_shell->copy->delete->touchfile->replace_all->rsync->last_do_shell.
Option group is control <xmltree>.
        eg:gameinstall=game,tomcat
                do->game->Operation
                do->tomcat->Operation
You can do:
      --gameinstall             Do xml game parser context.From <xmltree>.
      --update_tomcat           Display only security context and file name.
      --iptables_restart        This need root\'s administration authority.
      --debug_password          Print all debug messages!
      --config                  Lead into Config file!
      --xml                     Lead into xml file!
      --a                       Xml is append to default.xml.
      --help                    display this help and exit
      --version                 output version information and exit
      --option                  Option associate <xmltree branch="hello=tomcat"/>                                                              
                                --option hello

eg:     (1)
        ./Opackage --gameinstall        OR    ./Opackage --option gameinstall
        ./Opackage --update_tomcat      OR    ./Opackage --option update_tomcat
        ./Opackage --iptables_restart   OR    ./Opackage --option iptables_restart
        ./Opackage --gameinstall --config ./new_package.conf --debug_password \'key\'
        (2)
        xml_replace.axml replace same xml tree.eg: game->game
        ./Opackage --gameinstall --xml /export/a.xml 
        xml_append. a.xml append some operation to default.xml
        ./Opackage --gameinstall --xml /export/a.xml --a


Exit status is 0 if OK, 1 if minor problems, 2 if serious trouble.

Report bugs to <lienkai@wanmei.com>.';
	if ( $status == '2' ) {
		print "\nPlease check args input! eg: --update_tomcat --gameinstall --update_tomcat --iptables_restart or --help \n";
	}
	elsif ( $status == '0' ) {
		print '';

		print "\n";
	}
	else {
		print $info. "\n";
	}
	print $help_info. "\n";
	exit $status;
}

sub get_localtime {
	my ( $sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst ) = localtime(time);
	( $sec, $min, $hour, $mday, $mon, $year ) = ( sprintf( "%02d", $sec ), sprintf( "%02d", $min ), sprintf( "%02d", $hour ), sprintf( "%02d", $mday ), sprintf( "%02d", $mon + 1 ), $year + 1900 );
	my $time = "$year-$mon-$mday $hour:$min:$sec";
	return $time;
}

sub get_Second {
	my ( $time, $timelc, $sec, $min, $hour, $mday, $mon, $year );
	$time = $_[0];
	my @time = reverse( split /-|:|\s|,|\//, $time );
	foreach (@time) {

		#s/^0//;
		$timelc .= $_ . ",";
	}
	$timelc =~ s/,$//;
	( $sec, $min, $hour, $mday, $mon, $year ) = split /,/, $timelc;
	$sec  = "0" . $sec  if ( length($sec) == 1 );
	$min  = "0" . $min  if ( length($min) == 1 );
	$hour = "0" . $hour if ( length($hour) == 1 );
	$mday = "0" . $mday if ( length($mday) == 1 );
	$year -= 1900;
	$mon  -= 1;
	$mon = "0" . $mon if ( length($mon) == 1 );
	$timelc = timelocal( $sec, $min, $hour, $mday, $mon, $year );
	return $timelc;
}

sub get_snmp {
	my ( $servername, $snmpcmd ) = @_;
	my $snmpconfig = '/usr/bin/snmpwalk -v1 -c monitor ';
	$snmpcmd = $snmpconfig . $servername . " " . $snmpcmd;
	my @snmpinfo = qx|$snmpcmd 2>/dev/null|;
	return @snmpinfo;
}

sub get_HostIp {
	my @ARRAY = qx|awk \'/^1/ {print \$1}\' /etc/hosts|;
	my %hash = map { $_ => 1 } @ARRAY;
	@ARRAY = sort ( keys %hash );
	my @RESULTS;
	foreach my $subip (@ARRAY) {
		chomp($subip);
		next if ( $subip =~ m/254$/ or $subip =~ m/^127/ );
		my @ARRAY2 = gethostbyname "$subip";
		my ( $a1, $a2, $a3, $b1 ) = unpack( 'C4', $ARRAY2[4] );
		my $result = "$a1.$a2.$a3.$b1";
		push( @RESULTS, $result );
	}
	return @RESULTS;
}

sub printTimeInterval {
	my @Hostserver = get_HostIp();
	print "======================================================\n";
	print "                      All Check Start !               \n";
	print "======================================================\n";
	print "========= Server Interval Check ==============\n";
	foreach my $Aservername (@Hostserver) {
		my @GETTIME = get_snmp( $Aservername, 'HOST-RESOURCES-MIB::hrSystemDate.0' )
		  or print "$Aservername = NULL\n" and next;

		my $time = time();
		my $remotetime = $1 if ( $GETTIME[0] =~ /STRING: ([0-9\-:,]{1,20})/ );
		$remotetime = get_Second($remotetime);
		print "TimeCheck " . $Aservername . " = " . abs( $time - $remotetime ) . "\n";
	}
	print "======================================================\n";
	print "                      All Check Finished !            \n";
	print "======================================================\n";
}

####->调试程序所需所有方法集  ------------------------------------------------------------------------------
sub print_hash {
	my $ref = $_;
	while ( my ( $k, $v ) = each %$ref ) { print $k. "<   >" . $v . "\n"; }
}

sub tprint {
	my $ftime = localtime(time);
	if ( $debug ){
	$ftime =~ tr/ /_/;
	print "\n" . $ftime . "\n<---------------------------->\n";
	my $fuck     = "=====>>";
	my @arraytmp = @_;
	print BOLD, RED, "$fuck:$_\n", RESET for (@arraytmp);
	open LOG, ">>$debug_log";
	print LOG "$fuck:" . "$_\n" for (@arraytmp);
	close LOG;
	}
}

sub print_opt {

	#&print_opt();
	print '[' . $gameinstall . "] \t\t->gameinstall\n";
	print '[' . $option . "] \t\t->option\n";
	print '[' . $config . "] \t\t->conf\n";
	print '[' . $xml . "] \t\t->xmlfile\n";
	print '[' . $info . "] \t\t->info\n";
	print '[' . $debug_password . "] \t\t->debug_password\n";
	print '[' . $iptables_restart . "] \t\t->iptables_restart\n";
	print '[' . $update_tomcat . "] \t\t->update_tomcat\n";
	print '[' . $help . "] \t\t->help\n";
	print '[' . $kill . "] \t\t->kill\n";
	print '[' . $md5sum_files . "] \t\t->md5sum_files\n";
}

sub print_xml {
	my ($d) = @_;
	print "    ";
	print BOLD YELLOW $d->toString, RESET, "\n";
}

sub print_xml_blue {
	my ($d) = @_;
	print "   ";
	print BOLD BLUE $d->toString, RESET, "\n";
}

####->历史方法集

sub do_checkmd5file {
	###->system("cd $destdirname && md5sum -c allfile.md5 2>&1|grep -v OK");
	###->system("unix2dos $file 1>/dev/null 2>/dev/null") unless $iflinux;
}
