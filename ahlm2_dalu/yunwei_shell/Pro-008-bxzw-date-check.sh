#!/bin/bash
for i in `grep -v '#' /etc/hosts|awk '/buxiu_gs/{print $2}'` ; do echo -e "\033[34m${i}  : `ssh ${i} "date -R"`\e[0m" ; done
