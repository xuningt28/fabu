#!/bin/bash
backup1=`ls -l /export/server_bak/ahlm2/ahlm2_android/ |tail -5|awk '{print $9}'`
#backup2=`ls -l /export/server_bak/ahlm2/ahlm2_ledo/ |tail -5|awk '{print $9}'`
#backup3=`ls -l /export/server_bak/ahlm2/ahlm2_tx/ |tail -5|awk '{print $9}'`
mu1=/export/server_bak/ahlm2/ahlm2_android/
#mu2=/export/server_bak/ahlm2/ahlm2_ledo/
#mu3=/export/server_bak/ahlm2/ahlm2_tx/
cd $mu1 && rm -rf `ls -l |egrep -v "$backup1"|xargs`
#sleep 1
#cd $mu2 && rm -rf `ls -l |egrep -v "$backup2"|xargs`
#sleep 1
#cd $mu3 && rm -rf `ls -l |egrep -v "$backup3"|xargs`
