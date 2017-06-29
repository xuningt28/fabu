#!/bin/bash

start() {
         date  #
         /bin/sh /etc/fabu_server_13/ahlm2_dalu/tongbu_script/ahlm2.sh |grep -iE  'FAILED'  #
         echo "暗黑黎明2同步  result:$? " #
         date  #
         RETVAL=$?
         return $RETVAL
}


stop(){
        /bin/sh /etc/fabu_server_13/ahlm2_dalu/tongbu_script/ahlm2.sh
	rm -rf /etc/fabu_server_13/ahlm2_dalu/tongbu_script/ahlm2.pid
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
