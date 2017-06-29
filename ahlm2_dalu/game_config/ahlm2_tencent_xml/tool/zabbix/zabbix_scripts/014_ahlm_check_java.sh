#!/bin/bash
date_ago_3minute=`date +%Y-%m-%d' '%H:%M --date="-3 minute"`
date_ago_2minute=`date +%Y-%m-%d' '%H:%M --date="-2 minute"`
date_ago_1minute=`date +%Y-%m-%d' '%H:%M --date="-1 minute"`
gs_file_zoneid=`sudo grep ZONEID /root/gs.conf.m4  | awk '{print $2}' | sed 's/^.//' | sed 's/.\{5\}$//'`
gameserver_ago_1minute=`sudo grep -wc "${date_ago_1minute}.*begin" /export/logs/gsx.${gs_file_zoneid}.log`
gameserver_ago_2minute=`sudo grep -wc "${date_ago_2minute}.*begin" /export/logs/gsx.${gs_file_zoneid}.log`
gameserver_ago_3minute=`sudo grep -wc "${date_ago_3minute}.*begin" /export/logs/gsx.${gs_file_zoneid}.log`
gameserver_ago_12345=`sudo expr $gameserver_ago_1minute + $gameserver_ago_2minute + $gameserver_ago_3minute`

echo $gameserver_ago_12345
