#!/bin/bash
Src_dir="/export/new_fabu_server/bxzw_server/rsync"
Src_config="/etc/fabu_server_13/bxzw_dalu/game_config/"
Des_dir="/home/super/update/buxiugfpackage"
#Md5_file="/root/bxzw/bxzw_scripts/bxzwgf.md5"
Md5_file="/tmp/bxzwgf.md5"
flag=$1
cd $Src_dir
find   ./ -type f -print0 | xargs -0 md5sum > $Md5_file
for i in `grep -v '#' /etc/hosts|awk '/buxiu/{print $2}'` ; do
{
ssh -p 22 ${i} "\cp -r /home/super/update/buxiugfpackage/srcfile /home/super/update/buxiugfpackage/srcfile_`date +%Y%m%d_%H%M%S`"
}&
done
sleep 5
if [ $1 ];then
rsync -e "ssh -p 22" -avz --delete ${Src_dir}/ root@$1:${Des_dir}/srcfile
rsync -e "ssh -p 22" -avz --delete ${Src_config}  root@$1:${Des_dir}/config
rsync -e "ssh -p 22" -avz --delete $Md5_file  root@$1:${Des_dir}/srcfile
sleep 10
echo -e "${1}_FAILED:`ssh -p 22 ${i} "cd ${Des_dir}/srcfile;md5sum -c bxzwgf.md5  |grep -ic FAILED"`"
else
for i in `grep -v '#' /etc/hosts|awk '/buxiu/{print $2}'`; do 
{
rsync -e "ssh -p 22" -avz --delete ${Src_dir}/ root@$i:${Des_dir}/srcfile
rsync -e "ssh -p 22" -avz --delete ${Src_config}  root@$i:${Des_dir}/config
rsync -e "ssh -p 22" -avz --delete $Md5_file  root@$i:${Des_dir}/srcfile
sleep 10
echo -e "${i}_FAILED:`ssh -p 22 ${i} "cd ${Des_dir}/srcfile;md5sum -c bxzwgf.md5  |grep -ic FAILED"`"
}&
done
fi
