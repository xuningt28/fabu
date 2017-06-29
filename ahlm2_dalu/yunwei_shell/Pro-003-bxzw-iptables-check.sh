#!/bin/bash
for i in `grep -v '#' /etc/hosts|awk '/buxiu_gs/{print $2}'`;do
N=`ssh ${i} "/sbin/iptables -nL |awk '/28993,28994,28995,28996,28997,28998,28999,29000/'|wc -l"`
if [ ${N} -eq 1 ];then TYPE=[wai];else TYPE=[nei];fi
echo -e "\033[34m${i} iptables  state: ${TYPE} glink[1-8]politic number:`ssh ${i} "/sbin/iptables -nL |awk '/28993,28994,28995,28996,28997,28998,28999,29000/'|wc -l"`\e[0m";done
