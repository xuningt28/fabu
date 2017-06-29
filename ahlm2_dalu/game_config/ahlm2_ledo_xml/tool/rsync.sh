#!/bin/bash
####################################################
#执行脚本格式:sh rsync.sh 原服主机名  目标服主机名
#执行脚本格式:sh rsync.sh 原服主机名 原服主机名 等等 目标服主机名
####################################################

shi_jian=`date "+%F +%T"`

for i in `seq $#`;do
    eval yuan_db_name="$"$i
    eval mu_db_name="$"$#

    echo "$yuan_db_name -->>$mu_db_name"
    ssh $yuan_db_name "rm -rf /export/soft/$yuan_db_name"
    ssh $yuan_db_name "mkdir -p /export/soft/$yuan_db_name;cp -r /export/gsxdb /export/soft/$yuan_db_name/"
    ssh $yuan_db_name "cd /export/gsxdb;find ./ -type f -print0|xargs -0 md5sum > /export/soft/$yuan_db_name/he_md5.file"
    rm -rf /export/soft/ahlm2_xdb/$yuan_db_name
    rsync -azv $yuan_db_name:/export/soft/$yuan_db_name /export/soft/ahlm2_xdb/

    ssh $mu_db_name "rm -rf /export/soft/$yuan_db_name"
    rsync -azv /export/soft/ahlm2_xdb/$yuan_db_name $mu_db_name:/export/soft/


    echo "对比大小" >> /export/soft/ahlm2_xdb/md5.log
    echo `ssh $yuan_db_name "du -sh /export/gsxdb"` >> /export/soft/ahlm2_xdb/md5.log
    echo `ssh $yuan_db_name "du -sh /export/soft/$yuan_db_name/gsxdb"` >> /export/soft/ahlm2_xdb/md5.log
    echo `ssh $mu_db_name "du -sh /export/soft/$yuan_db_name/gsxdb"` >> /export/soft/ahlm2_xdb/md5.log




    echo "对比MD5"
    echo -e "$shi_jian \n对比MD5$yuan_db_name -->>$mu_db_name" >> /export/soft/ahlm2_xdb/md5.log
    echo `ssh $mu_db_name "cd /export/soft/$yuan_db_name/gsxdb;md5sum -c /export/soft/$yuan_db_name/he_md5.file |grep -vi \"ok\""` >> /export/soft/ahlm2_xdb/md5.log
done


echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++$shi_jian+++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n\n" >> /export/soft/ahlm2_xdb/md5.log
