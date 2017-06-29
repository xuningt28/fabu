#!/bin/bash
if [ -z ${1} ];then echo "ssh new_server.sh  [server number]" ;else
scp -P 22  /export/yunweizhiban/mazhongyue/new_server/sudoers ${1}:/etc/
rsync -avze "ssh -p 22" /export/yunweizhiban/mazhongyue/new_server/zabbix/ ${1}:/etc/zabbix/ ;fi
