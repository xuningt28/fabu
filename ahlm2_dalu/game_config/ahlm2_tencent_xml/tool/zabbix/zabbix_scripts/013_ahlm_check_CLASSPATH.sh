#!/bin/bash
# mail:liubowen@ledo.com
# version:v 1.1 date:2016-08-18


####################
# Check CLASSPATH  #
####################

javapid=`ps -ef | grep java | awk '/zoneid/ {print $2}'`

check_CLASSPATH_function () {
export | grep -wc 'CLASSPATH=".:/usr/java/default/lib/dt.jar:/usr/java/default/lib/tools.jar"'
}

check_CLASSPATH_function
