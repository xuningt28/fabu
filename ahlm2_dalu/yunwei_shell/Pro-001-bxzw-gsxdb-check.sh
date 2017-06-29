#!/bin/bash
#Modify:mazhongyue
#Date:2015-12-18
#E-mail:mazhongyue@ledo.com
echo -e "\033[37m==================================================================================================================================="
echo -e "\033[33mbxzw-13server-gsxdb.jar-MD5 : `md5sum /export/new_fabu_server/bxzw_server/rsync/gsxbin_export/gs/gsxdb.jar`"
for i in `grep -v '#' /etc/hosts|awk '/buxiu/{print $2}'` ; do echo -e "\033[33m${i}-home-gsxdb.jar-MD5 :" `ssh ${i} "md5sum /home/super/update/buxiugfpackage/srcfile/gsxbin_export/gs/gsxdb.jar 2>/dev/null"` ; done

echo -e "\033[37m==================================================================================================================================="

for i in `grep -v '#' /etc/hosts|awk '/buxiu/{print $2}'` ; do echo -e "\033[32m${i}-root-gsxdb.jar-MD5 :" `ssh ${i} "md5sum /root/server/gs/gsxdb.jar 2>/dev/null"` ; done

echo -e "\033[37m==================================================================================================================================="
