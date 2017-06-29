#/bin/bash
cp -r /export/new_fabu_server/bxzw_server/rsync /export/server_bak/ahlm2/ahlm2_android/srcfile_`date "+%F-%T"`
#cp -r /export/new_fabu_server/bxzw_ledo_server/rsync /export/server_bak/ahlm2/ahlm2_ledo/srcfile_`date "+%F-%T"`
#cp -r /export/new_fabu_server/bxzw_tencent_server/rsync /export/server_bak/ahlm2/ahlm2_tx/srcfile_`date "+%F-%T"`
curl -s http://192.168.252.240:8080/ledo_cmdb/game/xml |sed 's#\/>#\/>\n#g' > /etc/fabu_server_13/ahlm2_dalu/game_config/ahlm2_andriod_xml/t.xml
