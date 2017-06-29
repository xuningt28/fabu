#!/usr/bin/perl -w
use POSIX;
my $mu_ip="/etc/fabu_server_13/ahlm2_dalu/tongbu_script/ahlm2_andriod_list";
my $ssh_kou=22;
my @mu_lu=qw(/export/new_fabu_server/bxzw_server/rsync/ /etc/fabu_server_13/ahlm2_dalu/game_config/ahlm2_andriod_xml/ /etc/fabu_server_13/ahlm2_dalu/tongbu_script/ahlm2_andriod.md5);
my @mudi_lu=qw(/home/super/update/ahlm2package/srcfile /home/super/update/ahlm2package/config /home/super/update/ahlm2package/srcfile);
my $datea=qx#date "+%F-%T"#;
my $totala=$#mu_lu+1;

qx#cp -r $mu_lu[1] /export/config_bak/ahlm2/config$datea#;
qx#sh /etc/fabu_server_13/ahlm2_dalu/tongbu_script/Pro-101-ahlm-package_rsync.sh#;


if (@ARGV == 1){
my $jin_xing_zhonga=qx#ssh -p $ssh_kou $ARGV[0] hostname#;
qx#cd $mu_lu[0];find ./ -type f -print0 | xargs -0 md5sum > $mu_lu[2]#;
print "正在进行$jin_xing_zhonga....\n";
my $iii=0;
   for (`seq $totala`)
   {
   qx#/usr/bin/rsync -azve "ssh -p $ssh_kou" --delete --bwlimit 1000 $mu_lu[$iii] root\@$ARGV[0]:$mudi_lu[$iii]#;
   $iii+=1;
   }
print "=============开始检查MD5=============\n";
system("echo ==============`ssh -p $ssh_kou $ARGV[0] hostname`;ssh $ARGV[0] \"cd /home/super/update/ahlm2package/srcfile ;md5sum -c ./ahlm2_andriod.md5 |grep -iv ok\"");
system("echo ==`ssh -p $ssh_kou $ARGV[0] cat /home/super/update/ahlm2package/srcfile/version`");
print "=============MD5检查完毕=============\n";
exit 0;
}




my $zone=shift;
my @ip;
open (IN,"<$mu_ip") || die'error';
@ip=<IN>;
close(IN);
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
