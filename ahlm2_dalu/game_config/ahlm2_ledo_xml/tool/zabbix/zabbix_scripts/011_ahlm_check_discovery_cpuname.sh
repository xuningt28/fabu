#!/bin/bash
# mail:liubowen@ledo.com
# version:v 1.1 date:2016-08-18

###################
#cpuname_discovery#
###################

cpuname_discovery () {
    CpuName=($(/usr/bin/lscpu | awk 'NR==4{print $2}'))
    [ "${CpuName[0]}" == "" ] && exit
    printf '{\n'
    printf '\t"data":[\n'
    for((i=0;i<${CpuName};++i))
    {
          num=$(echo $((${CpuName})))
        if [ "$i" -lt `expr $num - 1` ];
        then
          printf "\t\t{ \n"
          printf "\t\t\t\"{#CPUNAME}\":\"${i}\"},\n"
        elif [ `expr $CpuName - 1` -eq "$i" ];
        then
            printf  "\t\t{ \n"
            printf  "\t\t\t\"{#CPUNAME}\":\"$i\"}]}\n"
        fi

   }
}
cpuname_discovery

