#!/bin/bash

login_w=`w |grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'|sort|uniq|grep -vE '10.10.|10.11.|192.168.|127.0.0.1'`
login_last=`last |grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'|sort|uniq|grep -vE '10.10.|10.11.|192.168.|127.0.0.1'`
login_secure=`grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}' /var/log/secure |sort |uniq|grep -vE '10.10.|10.11.|192.168.|123.56.17.95|127.0.0.1'`
login_pts=`ps -ef | grep pts|grep -o '[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}\.[0-9]\{1,3\}'|sort|uniq|grep -vE '10.10.|10.11.|192.168.|127.0.0.1'`

if [ "$login_w" = "" ] && [ "$login_last" = "" ] && [ "$login_secure" = "" ] && [ "$login_pts" = "" ];then
                echo "恢复"
                exit 1
else
        echo -n "$login_w $login_last $login_secure $login_pts"
fi

