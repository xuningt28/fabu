#!/bin/bash
# mail:liubowen@ledo.com
# version:v 1.1 date:2016-08-18

###############
# Game Online #
###############

sudo /usr/bin/java -cp /root/server/gs/lib/jmxc.jar jmxc controlRole JMXPASSWD 127.0.0.1 29023 GetMaxOnlineNum
