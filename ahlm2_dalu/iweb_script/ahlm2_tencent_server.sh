#!/bin/bash
mu_lu="/home/super/update/ahlm2package/srcfile"

case $1 in
start)
echo "==============同步开始============="  
date "+%F %T"  
perl /etc/fabu_server_13/ahlm2_dalu/tongbu_script/Pro-101-ahlm2_tencent-package_rsync.pl 
date "+%F %T"  
;;
esac
