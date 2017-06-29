#!/bin/bash
echo -e "\033[37m==================================================================================================================================="

echo -e "\033[33mbxzw-13server-hotdeploy1-MD5 : `md5sum /export/new_fabu_server/bxzw_server/rsync/gsxbin_export/gs/hotdeploy1.jar`"

for i in `grep -v '#' /etc/hosts|awk '/buxiu_gs/{print $2}'` ; do echo -e "\033[33m${i}-home_hotdeploy1-MD5 :" `ssh ${i} "md5sum /home/super/update/buxiugfpackage/srcfile/gsxbin_export/gs/hotdeploy1.jar"` ; done

echo -e "\033[37m==================================================================================================================================="

for i in `grep -v '#' /etc/hosts|awk '/buxiu_gs/{print $2}'` ; do echo -e "\033[34m${i}-root_hotdeploy1-MD5 :" `ssh ${i} "md5sum /root/server/gs/hotdeploy1.jar"` ; done

echo -e "\033[37m==================================================================================================================================="
