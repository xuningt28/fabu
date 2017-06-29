#!/bin/bash
# mail:liubowen@ledo.com
# version:v 1.1 date:2016-08-18

##################
#   Check Date   #
##################

check_date_function () {
check_time=`sudo ntpdate -q 0.centos.pool.ntp.org > /etc/zabbix/zabbix_log/ZabbixDiff_GameNtpTime.log`
check_time_status=`head -1 /etc/zabbix/zabbix_log/ZabbixDiff_GameNtpTime.log | awk -F' ' '{print $6}' | sed 's/\..*$//'`
time_status=`head -1 /etc/zabbix/zabbix_log/ZabbixDiff_GameNtpTime.log | awk -F' ' '{print $6}' | sed 's/\..*$//' | sed -n -r '1s/(.).*/\1/p'`

$check_time

if [ "$time_status" == '-' ];then
        echo "1"
else
   echo "$check_time_status"
fi
}

check_date_function
