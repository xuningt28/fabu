#!/usr/bin/perl
use XML::DOM;
my ($mu_lu,$mudi_lu);
my $ssh_kou=22;
my ($game_src,$game_md5,$game_config,$server_game_src,$game_cmdb);
my $game_flag ="./tb.xml";
my $type = $ARGV[0];

# 输入判断
if (!$ARGV[0]) {print "Usage: $0 game_flag ipaddress\n";exit};
$null_flag="tongbu_flag="."\""."${ARGV[0]}"."\"";
#{print err;exit;} unless ($a=qx#grep '$null_flag' $game_flag#);
unless ($a=qx#grep '$null_flag' $game_flag#) {print  "err game_name please check tb.xml\n";exit;}


#　xml 分析
sub ipt_xml()
{
my $flag = ();
my $parser = new XML::DOM::Parser;
my $doc = $parser->parsefile ("$game_flag");
my $nodes = $doc->getElementsByTagName ("tongbu");
my $n = $nodes->getLength;
my %ipt_hash;

for (my $i = 0; $i < $n; $i++)
 {
     my $node = $nodes->item ($i);                                                    
     my $tongbu_flag  = $node->getAttribute("tongbu_flag"); 
     print "$type\n";    
     print "$tongbu_flag\n"; 
     
     if ($tongbu_flag eq $type) 
                  {  print "ok\n";
		     $game_src=$node->getAttribute("game_src");
		     $game_md5=$node->getAttribute ("game_md5");
		     $game_config     = $node->getAttribute ("game_config");
		     $server_game_src = $node->getAttribute ("server_game_src");
		     $game_cmdb = $node->getAttribute ("game_cmdb");
		     push  (@mu_lu,($game_src,$game_config,$game_md5));                             
		     push  (@mudi_lu,($server_game_src,$game_config,$server_game_src));                             
                  }
     #else {exit;}
 }
}
ipt_xml();





#####                     #########
#####   old rsync.pl      #########
#####                     #########

#  单服务器同步   xml.pl kof  10.1.1.1
#
my $datea=qx#date "+%F-%T"#;  
my $totala=$#mu_lu+1;
#qx#cp -r $mu_lu[1] /export/config_bak/ahlm2/config$datea#;

if (@ARGV == 2){
print "dddddddddddddddddd\n";
my $jin_xing_zhonga=qx#ssh -p $ssh_kou $ARGV[1] hostname#;
qx#cd $mu_lu[0];find ./ -type f -print0 | xargs -0 md5sum > $mu_lu[2]#;
print "正在进行$jin_xing_zhonga....\n";
my $iii=0;
   for (`seq $totala`)
   {
   qx#/usr/bin/rsync -azve "ssh -p $ssh_kou" --delete --bwlimit 1000 $mu_lu[$iii] root\@$ARGV[1]:$mudi_lu[$iii]#;
   print "$mu_lu[$iii]   ---->  $mudi_lu[$uuu]\n";
   $iii+=1;
   }
print "=============开始检查MD5=============\n";

system("echo ==============`ssh -p $ssh_kou $ARGV[1] hostname`;ssh $ARGV[1] \"cd ${server_game_src} ;md5sum -c ./${game_md5} |grep -iv ok\"");
system("echo ==`ssh -p $ssh_kou $ARGV[1] cat ${server_game_src}/version`");
print "=============MD5检查完毕=============\n";
exit 0;
}


# 多服务器同步  xml.pl kof
#
my @ip;
@ip=`cat ${game_config}/ipxml.conf  |awk '{print \$1}'`;
qx#cd $mu_lu[0];find ./ -type f -print0 | xargs -0 md5sum > $mu_lu[2]#;
my $total=$#ip+1;
my $num=$total;
my $a=0;
my $bam=0;

$SIG{CHLD}=sub{$a--;$bam++};

my %pid;

while($total)
{
 if($a<20)
  {
   my $pid=fork();
   $pid{$pid}=1;
   if($pid == 0)
    {
      my $de=$num-$total;
      $ip[$de]=~s/\n//g;
      my $jin_xing_zhong=qx#ssh -p $ssh_kou $ip[$de] hostname#;
      print "正在进行$jin_xing_zhong....\n";
      my $ii=0;
        for (`seq $totala`)
        {
        qx#/usr/bin/rsync -azve "ssh -p $ssh_kou" --delete --bwlimit 1000 $mu_lu[$ii] root\@$ip[$de]:$mudi_lu[$ii] >/dev/null#;
        $ii+=1;
        }
      exit 0;
    }
   $a++;
   $total--;
   } 
  while($bam >0)
   {
     while(my $exit_pid=waitpid(-1,WNOHANG) > 0)
      {
        $bam--;
        if(exists($pid{$exit_pid})){delete $pid{$exit_pid};}
      }
   }
}

my @left=keys %pid;
if(@left)
 {
   foreach my $j(@left)
    {
        waitpid($j,0);
    }
 }
print "==============同步已结束\n";
print "=============请去rundeck检查《检查同步MD5》=============\n";
print "=============请去rundeck检查《检查同步MD5》=============\n";




#########  xml 文件配置示例   ##################
=cut
<?xml version="1.0" encoding="utf-8"?>
<Datas>
<tongbu  tongbu_flag="kof"  game_src="/export/new_fabu_server/kof_app_server/rsync/1"  game_config="/export/cmdb/new/kof_dalu/kof_dalu/ios/shangxian" game_md5="fabu.md5"  game_cmdb="cmdb_kof"  server_game_src="/home/super/update/kofyypackage/srcfiles"  server_game_conf="/home/super/update/kofyypackage/config" />
<tongbu  tongbu_flag="and"  game_src="/export/new_fabu_server/kof_app_server/rsync/2"  game_config="/export/cmdb/new/kof_dalu/kof_dalu/ios/shangxian" game_md5="fabu.md5"  game_cmdb="cmdb_and"  server_game_src="/home/super/update/kofyypackage/srcfiles"  server_game_conf="/home/super/update/kofyypackage/config" />
</Datas>
=cut
