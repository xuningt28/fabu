#!/bin/bash
# mail:liubowen@ledo.com
# version:v 1.1 date:2016-08-18


####################
# md5sum gsxdb.jar #
####################

md5sum_gsxdb_function () {
sudo md5sum /root/server/gs/gsxdb.jar|awk '{print $1}' > /etc/zabbix/zabbix_log/ZabbixDiff_GameGsxdbMd5.log
a=$(diff /etc/zabbix/zabbix_log/ZabbixDiff_13GsxdbMd5.log /etc/zabbix/zabbix_log/ZabbixDiff_GameGsxdbMd5.log)

if [ -z "$a" ] ; then
    echo `date +'%Y-%m-%d %H:%M:%S'` OK 
else

    echo  `date +'%Y-%m-%d %H:%M:%S'` Error  $a
fi
}

md5sum_gsxdb_function
