#!/bin/bash
#运行方式：nuofu.sh 目标服ip 源服ip


if [[ $# -eq 2 ]];then
date=`date +%F`
date_op=`date +%Y%M%d`
fu=`sudo ssh $2 "hostname"`
dir=/export/soft/$fu

sudo ssh $2 "mkdir -p $dir;rm -rf $dir/*"
sudo ssh $2 "sh /root/bin/stop_game.sh"
sleep 1
echo `sudo ssh $2 "ps aux |grep java|grep -v grep"` > /export/soft/lihongquan/nuofu_ahlm/stop_game_$fu.log
attention=`cat /export/soft/lihongquan/nuofu_ahlm/stop_game_$fu.log |grep server |wc -l`
if [ $attention -ne 0 ];then
exit 1
sudo ssh $2 "cd /export/gsxdb;find ./ -type f -print0|xargs -0 md5sum > $dir/nuo_md5.file"
sudo ssh $2 "cp -r /export/gsxdb $dir/;cp -r /export/logs/$date $dir/"
sudo ssh $2 "mkdir $dir/main;mkdir $dir/consume;cp -r /export/oplog/op/main/*$date_op* $dir/main/;cp -r /export/oplog/op/consume/*$date_op* $dir/consume/"
sudo ssh $2 "cd /export/soft;tar -zcf $fu.tar.gz $fu"
sudo rsync -avz root@$2:/export/soft/$fu.tar.gz /export/soft/lihongquan/nuofu_ahlm/
fi

echo `sudo ssh $1 "ps aux |grep java |grep -v grep"` > /export/soft/lihongquan/nuofu_ahlm/check_mu_$fu.log
attention=`cat /export/soft/lihongquan/nuofu_ahlm/check_mu_$fu.log |grep server |wc -l`
if [[ $attention -ne 0 ]];then
echo "目标服上有进程！！请查看！"
exit 2
else
sudo ssh $1 "mkdir -p /export/soft;mkdir -p /export/logs;mkdir -p /export/oplog/op/consume;mkdir -p /export/oplog/op/main"
sudo rsync -avz /export/soft/lihongquan/nuofu_ahlm/$fu.tar.gz $1:/export/soft/
fi

sudo ssh $1 "cd /export/soft;tar -zxf $fu.tar.gz"
sudo ssh $1 "cp -r $dir/gsxdb /export/;cp -r $dir/$date /export/logs/;cp -r $dir/main/* /export/oplog/op/main/;cp -r $dir/consume/* /export/oplog/op/consume/"
echo "----------------`date +%F-%H:%M`------------------" > /export/soft/lihongquan/nuofu_ahlm/md5_$fu.log
echo `ssh $1 "cd /export/gsxdb;md5sum -c $dir/he_md5.file |grep -vi ok"` >>/export/soft/lihongquan/nuofu_ahlm/md5_$fu.log
attention=`/export/soft/lihongquan/nuofu_ahlm/md5_$fu.log |grep FAILED |wc -l`
if [[ $attention -eq 0 ]];then
echo "++++++++++++++++++"
echo "挪服完成!"
echo "++++++++++++++++++"
else
echo "+++++++++++++++++++++++++++++"
echo "MD5核对有误，请登录查看！"
echo "+++++++++++++++++++++++++++++"
fi
else
echo "运行方式：nuofu.sh 目标服ip 源服ip"
fi
