#!/bin/bash
echo -e "\e[1;36m=====不朽之王=====\e[0m"
zong=0
for i in `grep -v '#' /etc/hosts|awk '/buxiu_gs/{print $2}'`;do
cha=`ssh  ${i} "sh /root/bin/GetMaxOnlineNum.sh|head -n 1"`
echo "${i}:" $cha
zong=$[$cha+$zong]
done
echo -e "\e[35m区服总人数:"$zong"\e[0m"
echo -e "\e[1;36m=====不朽之王=====\e[0m"
