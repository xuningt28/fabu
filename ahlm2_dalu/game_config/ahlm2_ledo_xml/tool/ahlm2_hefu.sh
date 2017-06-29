#!/bin/bash
can_shu=$#
mu=$1

jave_flag=`ps -ef |grep java |grep zoneid |grep -v "grep" |wc -l`
log_flag=`ps -ef |grep logservice.conf  |grep -v "grep" |wc -l`

stop_game (){
echo "" >/export/soft/ahlm2_xdb/stop_$mu.log
for i in `seq $#`;do
    eval name="$"$i
    sudo ssh $name "sh /root/bin/stop_game.sh"
    sleep 2
    echo `sudo ssh $name "ps aux |grep java|grep -v grep"` >> /export/soft/ahlm2_xdb/stop_$mu.log
done
attention=`cat /export/soft/ahlm2_xdb/stop_$mu.log |grep server |wc -l`
if [ $attention -ne 0 ];then
exit 1
fi
}


shuju (){
shi_jian=`date "+%F +%T"`

for i in `seq $#`;do
    eval yuan_db_name="$"$i
    eval mu_db_name="$"$#

    echo "$yuan_db_name -->>$mu_db_name"
    ssh $yuan_db_name "rm -rf /export/soft/$yuan_db_name*"
    ssh $yuan_db_name "mkdir -p /export/soft/$yuan_db_name;cp -r /export/gsxdb /export/soft/$yuan_db_name/"
    ssh $yuan_db_name "cd /export/gsxdb;find ./ -type f -print0|xargs -0 md5sum > /export/soft/$yuan_db_name/he_md5.file"
    ssh $yuan_db_name "cd /export/soft;tar -zcf $yuan_db_name\.tar.gz $yuan_db_name"
    rm -rf /export/soft/ahlm2_xdb/$yuan_db_name\.tar.gz
    rsync -azv $yuan_db_name:/export/soft/$yuan_db_name\.tar.gz /export/soft/ahlm2_xdb/

    ssh $mu_db_name "rm -rf /export/soft/$yuan_db_name*"
    rsync -azv /export/soft/ahlm2_xdb/$yuan_db_name\.tar.gz $mu_db_name:/export/soft/
    ssh $mu_db_name "cd /export/soft;tar -zxf $yuan_db_name\.tar.gz"


    echo "对比大小" >> /export/soft/ahlm2_xdb/md5_$mu_db_name.log
    echo `ssh $yuan_db_name "du -sh /export/gsxdb"` >> /export/soft/ahlm2_xdb/md5_$mu_db_name.log
    echo `ssh $yuan_db_name "du -sh /export/soft/$yuan_db_name/gsxdb"` >> /export/soft/ahlm2_xdb/md5_$mu_db_name.log
    echo `ssh $mu_db_name "du -sh /export/soft/$yuan_db_name/gsxdb"` >> /export/soft/ahlm2_xdb/md5_$mu_db_name.log

    echo "对比MD5"
    echo -e "$shi_jian \n对比MD5$yuan_db_name -->>$mu_db_name" >> /export/soft/ahlm2_xdb/md5_$mu_db_name.log
    echo `ssh $mu_db_name "cd /export/soft/$yuan_db_name/gsxdb;md5sum -c /export/soft/$yuan_db_name/he_md5.file |grep -vi \"ok\""` >> /export/soft/ahlm2_xdb/md5_$mu_db_name.log
done


echo -e "++++++++++++++++++++++++++++++++++++++++++++++++++++++++$shi_jian+++++++++++++++++++++++++++++++++++++++++++++++++++++\n\n\n" >> /export/soft/ahlm2_xdb/md5_$mu_db_name.log
attention=`cat /export/soft/ahlm2_xdb/md5_$mu_db_name.log|grep FAILED|wc -l`
if [ $attention -ne 0 ];then
cat /export/soft/ahlm2_xdb/md5_$mu_db_name.log
exit 2
fi

}

#src (){
#mkdir -p /export/nuofu
#rm  -fr  /export/nuofu/*
#ran=`date +%N |cut -c'1-4'`
#list=(/export/gsxdb /export/oplog /export/logs /export/nuofu/gsxdb.md5)
#ip=`ifconfig |awk -F: '/inet addr:172/{{sub("  Bcast","")}print $2}'`
#if [  $jave_flag -ne 0 ] 
#then
#echo "java进程运行中。。。。。请先关进程"
#exit

#elif [  $log_flag -ne 0 ] 
#then
#echo "log进程运行中。。。。。请先关进程"
#exit
#else
#find /export/gsxdb  -type f -print |xargs md5sum >> /export/nuofu/gsxdb.md5
#tar zcvf /export/nuofu/${ip}_${ran}.tar.gz ${list[0]} ${list[1]} ${list[2]} ${list[3]} 
#echo -e "当前区服为:`hostname` ip: ${ip}"
#read -p "输入目标ip: " dip
#echo "rsync -avz /export/nuofu/${ip}_${ran}.tar.gz ${dip}:/export/nuofu/" |bash 
#echo "脚本执行成功"
#fi
#}

#dest (){

#if [   $jave_flag -ne 0 ] 
#then
#echo "java进程运行中。。。。。请先关进程"
#exit

#elif [  $log_flag -ne 0 ] 
#then
#echo "log进程运行中。。。。。请先关进程"
#exit

#else
#mkdir -p /export/nuofu
#rm -fr /export/nuofu/*

#[ ! -d /export/old ] && mkdir /export/old
#rm -rf /export/old/`date +%Y%m%d`_oplog
#rm -rf /export/old/`date +%Y%m%d`_gsxdb
#rm -rf /export/old/`date +%Y%m%d`_logs
#mv  /export/oplog /export/old/`date +%Y%m%d`_oplog
#mv  /export/gsxdb /export/old/`date +%Y%m%d`_gsxdb
#mv  /export/logs /export/old/`date +%Y%m%d`_logs
#rm -vf /export/all.md5 &>/dev/null
#sleep 1
#rm -rf /root/server/*
#echo "脚本执行成功"
#fi
#}


tow_in_one (){
    mu_lu=` ssh $1 "ls /home/super/update/|grep ahlm"`
    echo -e "\e[32m正在进行二合一。。。。\e[0m"
    SRC1_DIR="/export/soft/$1/gsxdb"
    SRC2_DIR="/export/soft/$2/gsxdb"
    DEST_DIR="/export/soft/tow_in_db"
    stop_game $1 $2
    shuju $1 $2
    ssh $2 "rm -rf $DEST_DIR;mkdir -p $DEST_DIR"
    ssh $2 "cd /home/super/update/$mu_lu/srcfile/gsxbin_export/merge;sh xmerge.sh $SRC1_DIR $SRC2_DIR $DEST_DIR >/export/soft/he.log 2>&1"
    ssh $2 "cat /export/soft/he.log"
}

three_in_one (){
    mu_lu=` ssh $1 "ls /home/super/update/|grep ahlm"`
    echo -e "\e[32m正在进行三合一。。。。\e[0m"
    SRC1_DIR="/export/soft/$1/gsxdb"
    SRC2_DIR="/export/soft/$2/gsxdb"
    SRC3_DIR="/export/soft/$3/gsxdb"
    DEST1_DIR="/export/soft/dest1_3_db"
    DEST_DIR="/export/soft/three_in_db"
    stop_game $1 $2 $3
    shuju $1 $2 $3
    ssh $3 "rm -rf $DEST1_DIR;mkdir -p $DEST1_DIR"
    ssh $3 "rm -rf $DEST_DIR;mkdir -p $DEST_DIR"
    ssh $3 "cd /home/super/update/$mu_lu/srcfile/gsxbin_export/merge;sh xmerge.sh $SRC1_DIR $SRC3_DIR $DEST1_DIR >/export/soft/he.log 2>&1"

    sleep 10
    ssh $3 "cd /home/super/update/$mu_lu/srcfile/gsxbin_export/merge;sh xmerge.sh $SRC2_DIR $DEST1_DIR $DEST_DIR >/export/soft/he.log 2>&1"
    ssh $3 "cat /export/soft/he.log"
}

four_in_one (){
    mu_lu=` ssh $1 "ls /home/super/update/|grep ahlm"`
    echo -e "\e[32m正在进行四合一。。。。\e[0m"
    SRC1_DIR="/export/soft/$1/gsxdb"
    SRC2_DIR="/export/soft/$2/gsxdb"
    SRC3_DIR="/export/soft/$3/gsxdb"
    SRC4_DIR="/export/soft/$4/gsxdb"
    DEST1_DIR="/export/soft/dest1_4_db"
    DEST2_DIR="/export/soft/dest2_4_db"
    DEST_DIR="/export/soft/four_in_db"
    stop_game $1 $2 $3 $4
    shuju $1 $2 $3 $4
     ssh $4 "rm -rf $DEST1_DIR;mkdir -p $DEST1_DIR"
     ssh $4 "rm -rf $DEST2_DIR;mkdir -p $DEST2_DIR"
     ssh $4 "rm -rf $DEST_DIR;mkdir -p $DEST_DIR"
     ssh $4 "cd /home/super/update/$mu_lu/srcfile/gsxbin_export/merge;sh xmerge.sh $SRC1_DIR $SRC4_DIR $DEST1_DIR >/export/soft/he.log 2>&1"

    sleep 10
     ssh $4 "cd /home/super/update/$mu_lu/srcfile/gsxbin_export/merge;sh xmerge.sh $SRC2_DIR $SRC3_DIR $DEST2_DIR >/export/soft/he.log 2>&1"

    sleep 10
     ssh $4 "cd /home/super/update/$mu_lu/srcfile/gsxbin_export/merge;sh xmerge.sh $DEST2_DIR $DEST1_DIR $DEST_DIR >/export/soft/he.log 2>&1"
     ssh $4 "cat /export/soft/he.log"
}


five_in_one (){
    mu_lu=` ssh $1 "ls /home/super/update/|grep ahlm"`
    echo -e "\e[32m正在进行五合一。。。。\e[0m"
    SRC1_DIR="/export/soft/$1/gsxdb"
    SRC2_DIR="/export/soft/$2/gsxdb"
    SRC3_DIR="/export/soft/$3/gsxdb"
    SRC4_DIR="/export/soft/$4/gsxdb"
    SRC5_DIR="/export/soft/$5/gsxdb"
    DEST1_DIR="/export/soft/dest1_5_db"
    DEST2_DIR="/export/soft/dest2_5_db"
    DEST3_DIR="/export/soft/dest3_5_db"
    DEST_DIR="/export/soft/five_in_db"
    stop_game $1 $2 $3 $4 $5
    shuju $1 $2 $3 $4 $5
     ssh $5 "rm -rf $DEST1_DIR;mkdir -p $DEST1_DIR"
     ssh $5 "rm -rf $DEST2_DIR;mkdir -p $DEST2_DIR"
     ssh $5 "rm -rf $DEST3_DIR;mkdir -p $DEST3_DIR"
     ssh $5 "rm -rf $DEST_DIR;mkdir -p $DEST_DIR"
     ssh $5 "cd /home/super/update/$mu_lu/srcfile/gsxbin_export/merge;sh xmerge.sh $SRC1_DIR $SRC5_DIR $DEST1_DIR >/export/soft/he.log 2>&1"

    sleep 10
     ssh $5 "cd /home/super/update/$mu_lu/srcfile/gsxbin_export/merge;sh xmerge.sh $SRC2_DIR $SRC3_DIR $DEST2_DIR >/export/soft/he.log 2>&1"

    sleep 10
     ssh $5 "cd /home/super/update/$mu_lu/srcfile/gsxbin_export/merge;sh xmerge.sh $SRC4_DIR $DEST1_DIR $DEST3_DIR >/export/soft/he.log 2>&1"

    sleep 10
     ssh $5 "cd /home/super/update/$mu_lu/srcfile/gsxbin_export/merge;sh xmerge.sh $DEST2_DIR $DEST3_DIR $DEST_DIR >/export/soft/he.log 2>&1"
     ssh $5 "cat /export/soft/he.log"
}


if [[ $1 == "src" ]] && [[ $can_shu -eq 1 ]];then
    src
elif [[ $1 == "dest" ]] && [[ $can_shu -eq 1 ]];then
    dest
elif [[ $can_shu -eq 2 ]];then
    tow_in_one $1 $2
elif [[ $can_shu -eq 3 ]];then
    three_in_one $1 $2 $3
elif [[ $can_shu -eq 4 ]];then
    four_in_one $1 $2 $3 $4
elif [[ $can_shu -eq 5 ]];then
    five_in_one $1 $2 $3 $4 $5
else
    echo "请输入正确参数个数2个3个或4个5个"
    exit 2
fi

