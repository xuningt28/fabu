#!/bin/bash
echo -e "\033[37m==================================================================================================================================="

echo -e "\033[33mbxzw-13server-HotfixConfig-MD5 : `md5sum /export/new_fabu_server/bxzw_server/rsync/gsxbin_export/gs/gamedata/xml/auto/knight.gsp.HotfixConfig.xml`"
for i in `grep -v '#' /etc/hosts|awk '/buxiu_gs/{print $2}'` ; do echo -e "\033[33m${i}-home_HotfixConfig-MD5 :" `ssh ${i} "md5sum /home/super/update/buxiugfpackage/srcfile/gsxbin_export/gs/gamedata/xml/auto/knight.gsp.HotfixConfig.xml"` ; done

echo -e "\033[37m==================================================================================================================================="

for i in `grep -v '#' /etc/hosts|awk '/buxiu_gs/{print $2}'` ; do echo -e "\033[34m${i}-root_HotfixConfig-MD5 :" `ssh ${i} "md5sum /root/server/gs/gamedata/xml/auto/knight.gsp.HotfixConfig.xml"` ; done

echo -e "\033[37m==================================================================================================================================="
