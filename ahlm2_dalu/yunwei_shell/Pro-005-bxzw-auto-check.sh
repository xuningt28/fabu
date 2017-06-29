#!/bin/bash
read -p "please input:" AUTO
echo -e "\033[37m==================================================================================================================================="

for i in `grep -v '#' /etc/hosts|awk '/buxiu_gs/{print $2}'` ; do echo -e "\033[33m${i}-home_${AUTO}-MD5 :" `ssh ${i} "md5sum /home/super/update/buxiugfpackage/srcfile/gsxbin_export/gs/gamedata/xml/auto/${AUTO}"` ; done

echo -e "\033[37m==================================================================================================================================="

for i in `grep -v '#' /etc/hosts|awk '/buxiu_gs/{print $2}'` ; do echo -e "\033[32m${i}-root_${AUTO}-MD5 :" `ssh ${i} "md5sum /root/server/gs/gamedata/xml/auto/${AUTO}"` ; done

echo -e "\033[37m==================================================================================================================================="
