#!/bin/bash
start () {
    sh /etc/fabu_server_13/monit_xml/tongbu_script/Pro-101-all-xml-rsync.sh ahlm2_dalu
}

case $1 in
start)
    start
;;
esac
