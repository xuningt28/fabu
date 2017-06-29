#!/bin/bash
MD5=`md5sum /export/new_fabu_server/bxzw_server/rsync/gsxbin_export/gs/gsxdb.jar |awk '{print $1}'`
for i in `grep -v '#' /etc/hosts |awk '/buxiu/{print $2}'`;do ssh ${i} "echo -e "${MD5}" >/etc/zabbix/zabbix_scripts/ZabbixDiff_13GsxdbMd5.log" ;done
