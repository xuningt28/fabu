#!/bin/bash
# mail:liubowen@ledo.com
# version:v 1.1 date:2016-08-18

################
# Game Process #
################

parameter=$1
case $parameter in

\[g]linkd1)
		sudo /bin/ps -ef | grep -wc $parameter
		;;
\[g]linkd2)
		sudo /bin/ps -ef | grep -wc $parameter
		;;
\[g]linkd3)
		sudo /bin/ps -ef | grep -wc $parameter
		;;
\[g]linkd4)
		sudo /bin/ps -ef | grep -wc $parameter
		;;
\[g]linkd5)
		sudo /bin/ps -ef | grep -wc $parameter
		;;
\[g]linkd6)
		sudo /bin/ps -ef | grep -wc $parameter
		;;
\[g]linkd7)
		sudo /bin/ps -ef | grep -wc $parameter
		;;
\[g]linkd8)
		sudo /bin/ps -ef | grep -wc $parameter
		;;
\[d]eliver)
		sudo /bin/ps -ef | grep -wc $parameter
		;;
\[j]ava)
		sudo /bin/ps -ef | grep -wc $parameter
		;;

esac
