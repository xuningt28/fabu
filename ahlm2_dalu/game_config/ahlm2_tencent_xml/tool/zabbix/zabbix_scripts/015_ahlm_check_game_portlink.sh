#!/bin/bash
serverprocess=`ps -ef | grep -wc [s]erver`
linkportsum=`sudo /bin/netstat -nlt | grep -E -c '2899|29000'`
auportsum=`sudo /bin/netstat -anpt | grep -E '29017|29200|21100'|grep -wc [E]STABLISHED|grep -v glinkd`
if [ "${serverprocess}" -ge "11" ] && [ "${linkportsum}" = "8" ] && [ "${auportsum}" -ge "3" ];then
        echo "恢复"
        exit 1
else
glinkd1=`ps -ef | grep -wc [g]linkd1`
glinkd2=`ps -ef | grep -wc [g]linkd2`
glinkd3=`ps -ef | grep -wc [g]linkd3`
glinkd4=`ps -ef | grep -wc [g]linkd4`
glinkd5=`ps -ef | grep -wc [g]linkd5`
glinkd6=`ps -ef | grep -wc [g]linkd6`
glinkd7=`ps -ef | grep -wc [g]linkd7`
glinkd8=`ps -ef | grep -wc [g]linkd8`
port28993=`sudo /bin/netstat -nlt | grep -wc [2]8993`
port28994=`sudo /bin/netstat -nlt | grep -wc [2]8994`
port28995=`sudo /bin/netstat -nlt | grep -wc [2]8995`
port28996=`sudo /bin/netstat -nlt | grep -wc [2]8996`
port28997=`sudo /bin/netstat -nlt | grep -wc [2]8997`
port28998=`sudo /bin/netstat -nlt | grep -wc [2]8998`
port28999=`sudo /bin/netstat -nlt | grep -wc [2]8999`
port29000=`sudo /bin/netstat -nlt | grep -wc [2]9000`
port29017=`sudo /bin/netstat -anpt | grep [2]9017|grep -wc [E]STABLISHED`
port29200=`sudo /bin/netstat -anpt | grep [2]9200|grep -wc [E]STABLISHED`
port29033=`sudo /bin/netstat -anpt | grep [2]1100|grep -wc [E]STABLISHED`
javaprocess=`ps -ef | grep -wc [j]ava`
deliverd=`ps -ef | grep -wc [g]deliverd`
if [  "${glinkd1}" != "1" ];then
        echo -n "glinkd1,"
        fi
if [ "${glinkd2}" != "1" ];then
        echo -n "glinkd2," 
        fi
if [ "${glinkd3}" != "1" ];then
        echo -n "glinkd3," 
        fi
if [ "${glinkd4}" != "1" ];then
        echo -n "glinkd4," 
        fi
if [ "${glinkd5}" != "1" ];then
        echo -n "glinkd5," 
        fi
if [ "${glinkd6}" != "1" ];then
        echo -n "glinkd6,"
        fi 
if [ "${glinkd7}" != "1" ];then
        echo -n "glinkd7,"
        fi 
if [ "${glinkd8}" != "1" ];then
        echo -n "glinkd8," 
        fi
if [ "${port28993}" != "1" ];then
        echo -n "port28993,"
        fi 
if [ "${port28994}" != "1" ];then
        echo -n "port28994," 
        fi
if [ "${port28995}" != "1" ];then
        echo -n "port28995," 
        fi
if [ "${port28996}" != "1" ];then
        echo -n "port28996," 
        fi
if [ "${port28997}" != "1" ];then
        echo -n "port28997," 
        fi
if [ "${port28998}" != "1" ];then
        echo -n "port28998," 
        fi
if [ "${port28999}" != "1" ];then
        echo -n "port28999,"
        fi 
if [ "${port29000}" != "1" ];then
        echo -n "port29000," 
        fi
if [ "${port29017}" = "0" ];then
        echo -n "port29017," 
        fi
if [ "${port21100}" = "0" ];then
        echo -n "port21100," 
        fi
if [ "${port29200}" = "0" ];then
        echo -n "port29200," 
        fi
if [ "${javaprocess}" -lt "2" ];then
        echo -n "javaprocess," 
        fi
if [ "${deliverd}" != "1" ];then
        echo -n "deliverd." 
fi
fi
