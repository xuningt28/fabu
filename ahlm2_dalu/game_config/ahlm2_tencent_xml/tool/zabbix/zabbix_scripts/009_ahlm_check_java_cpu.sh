#!/bin/bash
# mail:liubowen@ledo.com
# version:v 1.1 date:2016-08-18


######################
# Check java CPU use #
######################

javapid=`ps -ef | grep java | awk '/zoneid/ {print $2}'`

check_Cpu_function () {
sudo /usr/bin/top -p $javapid -bn 1 | awk '/java/ {print $9}' | awk -F '.' '{print $1}'
}
             
check_Cpu_function
