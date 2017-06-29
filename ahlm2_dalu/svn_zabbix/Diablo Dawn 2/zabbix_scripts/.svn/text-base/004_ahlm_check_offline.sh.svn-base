#!/bin/bash
# mail:liubowen@ledo.com
# version:v 1.1 date:2016-08-18


##################
#  Check offline #
##################

check_offline_function () {
check_onlinesum_add=`sudo /bin/sed -i '1d;' /etc/zabbix/zabbix_log/ZabbixDiff_GameOffline.log;sudo /usr/java/default/bin/java -cp /root/server/gs/lib/jmxc.jar jmxc controlRole JMXPASSWD 127.0.0.1 29023 GetMaxOnlineNum |head -n 1 >> /etc/zabbix/zabbix_log/ZabbixDiff_GameOffline.log`
check_onlinesum_status=`sudo /bin/awk '{getline a;print int(($0-a))}' /etc/zabbix/zabbix_log/ZabbixDiff_GameOffline.log |sudo /bin/sed -n -r '1s/(.).*/\1/p'`
check_status=`sudo /bin/awk '{getline a;print int(($0-a))}' /etc/zabbix/zabbix_log/ZabbixDiff_GameOffline.log`
check_hang=`sudo /bin/cat /etc/zabbix/zabbix_log/ZabbixDiff_GameOffline.log|wc -l`
check_shu=`sudo /bin/cat /etc/zabbix/zabbix_log/ZabbixDiff_GameOffline.log|head -n 1`

if [ "$check_hang" == '2' ];then
        $check_onlinesum_add
else
        echo -e "$check_shu\n$check_shu" >/etc/zabbix/zabbix_log/ZabbixDiff_GameOffline.log
fi

$check_onlinesum_add

if [ "$check_onlinesum_status" == '-' ];then
        echo "1"
else
   echo "$check_status"
fi
}


check_offline_function


