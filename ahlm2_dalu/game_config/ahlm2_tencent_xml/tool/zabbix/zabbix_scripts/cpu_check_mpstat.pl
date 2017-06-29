#!/usr/bin/perl

use strict;
use warnings;

# 功能说明：调用mpstat命令统计CPU各个核心使用率，并将结果保存在/tmp/cpu_check_mpstat，如果连续三次CPU空闲率低于3%，则报警。
# 结果记录格式：时间点\tCPU核心编号\tCPU空闲率\tCPU空闲率\tCPU空闲率
# 输出值：error:报警CPU核心编号1,报警CPU核心编号2,... 有报警及相应核心编号；ok 无报警

my $idle_threadhold = 3;
my $now = `date +%F" "%H:%M:00`;
chomp($now);
my $mpstat = qx#whereis mpstat#;
chomp($mpstat);
if ($mpstat =~ /^mpstat:$/){
    print "0";
    exit(1);
}
my @results = qx#mpstat  -P ALL 1 1 |grep -v all |grep -v "^Average" |awk '{print \$3" "\$NF}'#;
my $out_file = "/tmp/cpu_check_mpstat";
if (not -f $out_file){
    qx#touch $out_file#;
}
my %ex_records;
my %alert_records;
# 读取历史记录文件
open OF, "$out_file";
foreach my $line (<OF>){
    chomp($line);
    if ($line =~ /(\d+-\d+-\d+ \d+:\d+:\d+)\s+(\d+)\s+(.+)$/){
        my $cpu_no = $2;
        my $cpu_idle_line = $3;
        $ex_records{$cpu_no} = $cpu_idle_line;
     }
}
close OF;

# 用最新取到的CPU空闲率替换历史文件中最早的一次记录
open OF, ">$out_file";
foreach my $result (@results){
    chomp($result);
    if ($result =~ /(\d+)\s+(\d+\.?\d+)$/){
        my $cpu_no = $1;
        my $cpu_idle = $2;
        my $ex_cpu_idle_line = $ex_records{$cpu_no};
        my @ex_cpu_idles;
        if ($ex_cpu_idle_line){
            @ex_cpu_idles = split(/\s+/, $ex_cpu_idle_line);
            if (scalar(@ex_cpu_idles) >= 3){
                shift @ex_cpu_idles;
            }
        }
        push @ex_cpu_idles, $cpu_idle;
        my $cpu_idle_line = $now . "\t" . $cpu_no . "\t" . join("\t", @ex_cpu_idles);
        print OF $cpu_idle_line . "\n";
        my $alert = 1;
        foreach my $ex_cpu_idle (@ex_cpu_idles){
            if ($ex_cpu_idle > $idle_threadhold){
                # 3条记录中，有任意一条的CPU空闲值超过3，则不需要报警
                $alert = 0;
            }
        }
        if ($alert and scalar(@ex_cpu_idles) >= 3){
            $alert_records{"$cpu_no"} = $cpu_idle_line;
        }
        
    }
}
close OF;
if (scalar(keys %alert_records) <= 0){
    print "ok";
}else{
    print "error:" . join(",", (keys %alert_records));
}

