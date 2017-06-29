#!/bin/bash
for i in `grep -v '#' /etc/hosts|awk '/buxiu_gs/{print $2}'`;do
{
echo "${i} Start Backup"
ssh ${i} "cp -r /export/gsxdb /export/gsxdb_`date +%y%m%d%H%M`"
echo "${i} cp /export/gsxdb to /export/gsxdb_`date +%y%m%d%H%M` is [ok]" 
}&
done
