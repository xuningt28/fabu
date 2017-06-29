#!/bin/bash
buxiu=buxiu_gs
port=22
[ $# -eq 0 ]&& echo -e  "\e[31mplease input sh auto.sh ahgame [ 1 2 3 ] \e[0m" && exit
if [[ $3 == "-" ]] ;then
	if [[ $1 == $buxiu ]];then
          read -p "input Command:" Command
          for i in `seq $2 $4`;do
          echo -e "\e[31m$buxiu$i: `ssh -p $port $1$i $Command`\e[0m"
          done
          exit
        else
          echo -e  "\e[31minput error exit\e[0m"
          exit
        fi
elif [ $# -eq 2 ];then
        if [[ $1 == $buxiu ]];then
          read -p "input Command:" Command
          echo -e "\e[31m$buxiu$2: `ssh -p $port $1$2 $Command`\e[0m"
          exit
        else
          echo -e  "\e[31minput error exit\e[0m"
          exit
        fi
elif [ $# -gt 2 ];then
	  if [[ $1 == $buxiu ]];then
          read -p "input Command：" Command
          for i in `seq $[$#-1]`;do
          echo -e "\e[31m$buxiu$2: `ssh -p $port $buxiu$2 $Command`\e[0m"
          shift
          done
          exit
        else
          echo -e  "\e[31minput error exit\e[0m"
        fi
else
        echo -e  "\e[31minput error exit\e[0m"
fi
