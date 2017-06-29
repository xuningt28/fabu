#!/bin/bash

start() {
         date  >> /var/log/monit.log
         /bin/sh /etc/fabu_server_13/ahlm2_dalu/tongbu_script/ahlm2_ledo.sh |grep -iE  'FAILED'  >> /var/log/monit.log
         echo "暗黑黎明2乐道IOS同步  result:$? " >> /var/log/monit.log
         date  >> /var/log/monit.log
         RETVAL=$?
         return $RETVAL
}


stop(){
        /bin/sh /etc/fabu_server_13/ahlm2_dalu/tongbu_script/ahlm2_ledo.sh
	rm -rf /etc/fabu_server_13/ahlm2_dalu/tongbu_script/ahlm2_ledo.pid
}

# See how we were called.
case "$1" in
  start)
	start
	;;
  stop)
	stop
	;;
*)
        echo $"Usage: $0 {start|stop|status|restart|try-restart|force-reload}"
        exit 2
esac
