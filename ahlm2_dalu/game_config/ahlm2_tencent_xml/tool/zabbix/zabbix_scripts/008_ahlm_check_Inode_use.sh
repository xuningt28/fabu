#!/bin/bash
# mail:liubowen@ledo.com
# version:v 1.1 date:2016-08-18

parameter=$1
case $parameter in

IFreeRoot)
                expr 100 - `sudo /bin/df -i / | awk 'NR==2{print $5}' | sed 's/%//'`
                ;;
IFreeExport)
                expr 100 - `sudo /bin/df -i /export | awk 'NR==2{print $5}' | sed 's/%//'`
                ;;
IUseRoot)
                sudo /bin/df -i / | awk 'NR==2{print $5}' | sed 's/%//'
                ;;
IUseExport)
                sudo /bin/df -i /export | awk 'NR==2{print $5}' | sed 's/%//'
                ;;
IUseRoot_docker)
                sudo /bin/df -i / | awk 'NR==3{print $4}' | sed 's/%//'
                ;;

esac
