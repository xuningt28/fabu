#!/bin/bash
# mail:liubowen@ledo.com
# version:v 1.1 date:2016-08-18

######################
# Check java Mem use #
######################

javapid=`ps -ef | grep java | awk '/zoneid/ {print $2}'`

check_Mem_function () {
sudo /usr/bin/top -p $javapid -bn 1 | awk '/java/ {print $10}' | awk -F '.' '{print $1}'
}

check_Mem_function

