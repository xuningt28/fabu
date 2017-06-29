#!/bin/bash
shi_jian=`date "+%F-%T"`
Src_dir="/export/new_fabu_server/bxzw_tencent_server/rsync"
Src_config="/etc/fabu_server_13/ahlm2_dalu/game_config/ahlm2_tencent_xml/"
Des_dir="/home/super/update/ahlm2package"
Md5_file="/etc/fabu_server_13/ahlm2_dalu/tongbu_script/ahlm2_tencent.md5"

cp -r $Src_config /export/config_bak/ahlm2/game_config"$shi_jian"
cp -r $Src_dir /export/server_bak/ahlm2/ahlm2_tx/srcfile_"$shi_jian"
curl -s http://192.168.252.240:8080/ledo_cmdb/game/xml |sed 's#\/>#\/>\n#g' > "$Src_config"t.xml

flag=$1
cd $Src_dir
find   ./ -type f -print0 | xargs -0 md5sum > $Md5_file
#for i in `cat /etc/fabu_server_13/ahlm2_dalu/tongbu_script/ahlm2_tencent_list` ; do
#{
#ssh -p 22 ${i} "\cp -r /home/super/update/ahlm2package/srcfile /home/super/update/ahlm2package/srcfile_`date +%Y%m%d_%H%M%S`"
#}&
#done
#sleep 5
if [ $1 ];then
rsync -e "ssh -p 22" -avz --delete ${Src_dir}/ root@$1:${Des_dir}/srcfile
rsync -e "ssh -p 22" -avz --delete ${Src_config}  root@$1:${Des_dir}/config
rsync -e "ssh -p 22" -avz --delete $Md5_file  root@$1:${Des_dir}/srcfile
sleep 10
echo -e "${1}_FAILED:`ssh -p 22 ${i} "cd ${Des_dir}/srcfile;md5sum -c ahlm2_tencent.md5  |grep -ic FAILED"`"
else
for i in `cat /etc/fabu_server_13/ahlm2_dalu/tongbu_script/ahlm2_tencent_list`; do 
{
rsync -e "ssh -p 22" -avz --delete ${Src_dir}/ root@$i:${Des_dir}/srcfile >/dev/null
rsync -e "ssh -p 22" -avz --delete ${Src_config}  root@$i:${Des_dir}/config >/dev/null
rsync -e "ssh -p 22" -avz --delete $Md5_file  root@$i:${Des_dir}/srcfile >/dev/null
sleep 10
echo -e "${i}_FAILED:`ssh -p 22 ${i} "cd ${Des_dir}/srcfile;md5sum -c ahlm2_tencent.md5  |grep -ic FAILED"`"
}&
done
fi
