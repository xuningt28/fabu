#!/bin/bash
# mail:liubowen@ledo.com
# version:v 1.1 date:2016-08-18

####################
#diskname_discovery#
####################

diskname_discovery(){
    HardDisk=($(grep '\b[a-z][a-z][a-z]\+\b'  /proc/diskstats|awk '{print $3}'))
    [ "${HardDisk[0]}" == "" ] && exit
    printf '{\n'
    printf '\t"data":[\n'
    for((i=0;i<${#HardDisk[@]};++i))
    {
        num=$(echo $((${#HardDisk[@]}-1)))
        if [ "$i" != ${num} ];
        then
           printf "\t\t{ \n"
           printf "\t\t\t\"{#DISKNAME}\":\"${HardDisk[$i]}\"},\n"
        else
           printf  "\t\t{ \n"
           printf  "\t\t\t\"{#DISKNAME}\":\"${HardDisk[$num]}\"}]}\n"
        fi
	}
}
diskname_discovery

