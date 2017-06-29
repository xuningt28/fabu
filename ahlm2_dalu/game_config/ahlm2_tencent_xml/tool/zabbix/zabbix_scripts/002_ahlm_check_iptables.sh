#!/bin/bash
# mail:liubowen@ledo.com
# version:v 1.1 date:2016-08-18


##################
#  Check Iptabes #
##################

check_iptables_function () {
sudo /sbin/iptables-save |grep -Ev  "^\b|^:|^#|^\*"  > /etc/zabbix/zabbix_log/ZabbixDiff_GameIptablesCurrent.log
a=$(diff /etc/zabbix/zabbix_log/ZabbixDiff_GameIptablesMoban.log /etc/zabbix/zabbix_log/ZabbixDiff_GameIptablesCurrent.log |grep -E ">" |sed 's/>//g' |tr "\n" " ")

if [ -z "$a" ] ; then
    echo `date +'%Y-%m-%d %H:%M:%S'` OK 
else
    echo  `date +'%Y-%m-%d %H:%M:%S'` Error  $a
fi
}

check_iptables_function

