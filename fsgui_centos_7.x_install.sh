#!/bin/bash
basepath=$(cd `dirname $0`; pwd)
echo "脚本执行命令"
installPath=$1;
defaultInstallPath=/root/fsgui-install;
if  [ ! -n "$installPath" ] ;then
    echo "未设置安装路径，使用默认路径："$defaultInstallPath
	installPath=$defaultInstallPath
fi
cd /root
wget https://qzlink.oss-cn-beijing.aliyuncs.com/downloads/linux/install/server-environ-install.sh
sh server-environ-install.sh |tee server-environ-install.log

mkdir $installPath
cd $installPath

#下载安装文件
wget http://qzlink.oss-cn-beijing.aliyuncs.com/fsgui/install/UnlimitedJCEPolicyJDK8.zip
wget http://qzlink.oss-cn-beijing.aliyuncs.com/fsgui/install/freeswitch_d
wget http://qzlink.oss-cn-beijing.aliyuncs.com/fsgui/install/fsgui-admin-web.war
wget http://qzlink.oss-cn-beijing.aliyuncs.com/fsgui/install/fsgui-api-release.zip
wget http://qzlink.oss-cn-beijing.aliyuncs.com/fsgui/install/jdk-8u73-linux-x64.rpm
wget http://qzlink.oss-cn-beijing.aliyuncs.com/fsgui/install/monitor.sh
wget http://qzlink.oss-cn-beijing.aliyuncs.com/fsgui/install/mysql-community-release-el6-5.noarch.rpm
wget http://qzlink.oss-cn-beijing.aliyuncs.com/fsgui/install/tomcat.zip
wget http://qzlink.oss-cn-beijing.aliyuncs.com/fsgui/install/updateIP.sh
wget http://qzlink.oss-cn-beijing.aliyuncs.com/fsgui/install/freeswitch_7.6.green.zip

mv /etc/my.cnf /etc/my.cnf.old
echo '
[freeswitch]
DRIVER = MySQL
SERVER = DBIP
PORT = DBPort
DATABASE = DBNAME
USER = DBUSER
PASSWORD = DBPASS
OPTION = 67108864
'> /etc/odbc.ini
 
echo '
[mysqld]
server_id=1
log_bin     = /var/lib/mysql/mysql-bin
binlog_format   = mixed
pid-file    = /var/run/mysqld/mysqld.pid 
datadir     = /var/lib/mysql
symbolic-links  =0
expire_logs_days = 7
max_binlog_size = 500M
character_set_server=utf8
collation-server=utf8_general_ci
[mysql]
default-character-set=utf8
[client]
default-character-set=utf8
[mysqld_safe]
log-error=/var/log/mysqld.log
pid-file=/var/run/mysqld/mysqld.pid
'> /etc/my.cnf

cd /home
#wget https://hk-area1-file.oss-cn-hongkong.aliyuncs.com/fsgui/tomcat.zip
\cp -r $installPath/tomcat.zip ./
unzip tomcat.zip 
rm -rf tomcat.zip
chmod a+x /home/tomcat/bin/*.sh 

cd /home
#wget https://hk-area1-file.oss-cn-hongkong.aliyuncs.com/fsgui/fsgui-api-release.zip
#wget https://hk-area1-file.oss-cn-hongkong.aliyuncs.com/fsgui/fsgui-admin-web.war
\cp -r $installPath/fsgui-api-release.zip ./
\cp -r $installPath/fsgui-admin-web.war ./
mkdir /home/tomcat/webapps/ROOT
mv /home/fsgui-admin-web.war /home/tomcat/webapps/ROOT 
cd /home/tomcat/webapps/ROOT/ && unzip fsgui-admin-web.war && rm -rf fsgui-admin-web.war
cd /home
yes|unzip fsgui-api-release.zip
rm -rf fsgui-api-release.zip 


# 下面这个用为rtc2sip 转化  1.6.20
#ADD freeswitch /usr/local/freeswitch
###下面的是FSGUI的环境 1.6.15
#rm -rf /usr/local/*
#touch /usr/local/readme

#change for default DSN info 
mkdir /usr/local/freeswitch/etc
ln -s /etc/odbcinst.ini /usr/local/freeswitch/etc/odbcinst.ini
ln -s /etc/odbc.ini /usr/local/freeswitch/etc/odbc.ini

cd /usr/local
#wget https://hk-area1-file.oss-cn-hongkong.aliyuncs.com/fsgui/centos7.7_freeswitch_1.10.2-release_green_only_8000hz.zip
\cp -r $installPath/freeswitch_7.6.green.zip ./
unzip -o freeswitch_7.6.green.zip
rm -rf freeswitch_7.6.green.zip
###
###
cd $installPath
echo "->start install freeswitch..."
mkdir -p /usr/local/freeswitch/rh
#wget https://hk-area1-file.oss-cn-hongkong.aliyuncs.com/fsgui/freeswitch_d

#下面是复制  ADD 是移动
# cp -f freeswitch_d /etc/rc.d/init.d/freeswitch
\cp -r freeswitch_d /etc/rc.d/init.d/freeswitch
chmod a+x /etc/rc.d/init.d/freeswitch
chkconfig --add freeswitch
chkconfig freeswitch on

#yes|wget https://hk-area1-file.oss-cn-hongkong.aliyuncs.com/fsgui/monitor.sh
chmod a+x monitor.sh
yes|\cp -r monitor.sh /usr/local/freeswitch/bin/monitor.sh
#找不到文件报错
# cp -f monitor.sh /usr/local/freeswitch/bin/monitor.sh
chmod a+x /usr/local/freeswitch/bin/monitor.sh
sed -i '/monitor.sh/d' /etc/rc.d/rc.local
sed -i '/sleep 5/d' /etc/rc.d/rc.local
sed -i '$a\/usr/local/freeswitch/bin/monitor.sh &' /etc/rc.d/rc.local
sed -i '$asleep 5' /etc/rc.d/rc.local
echo "->install OK.."
#rm -rf monitor.sh

#wget https://hk-area1-file.oss-cn-hongkong.aliyuncs.com/fsgui/updateIP.sh .
rm -rf ./getIP*
wget http://license.qzlink.com/getIP
chmod a+x  updateIP.sh
cat getIP|sh updateIP.sh 
sh updateIP.sh `cat getIP`
# rm -rf updateIP.sh

#rm -rf monitor.sh
#rm -rf freeswitch_d
ln -sf /usr/local/freeswitch/bin/freeswitch /usr/local/bin/
ln -sf /usr/local/freeswitch/bin/fs_cli /usr/local/bin/

ln -sf /usr/local/freeswitch/bin/freeswitch /usr/bin/
ln -sf /usr/local/freeswitch/bin/fs_cli /usr/bin/

#rm -rf anaconda-ks.cfg  install.log  install.log.syslog
#rm -rf jdk-8u73-linux-x64.rpm
ln -sf /usr/local/freeswitch /root/fs_home
#rm -rf mysql-community-release-el6-5.noarch.rpm


#add gateway
echo '
<gateway name="default_gw">
<param name="realm" value="47.52.229.136:5080" />
<param name="proxy" value="47.52.229.136:5080" />
<param name="register" value="false" />
<param name="caller-id-in-from" value="true"/>
<param name="expire-seconds" value="30"/>
<param name="retry_seconds" value="30"/>
<param name="ping" value="10"/>
</gateway>
'>/usr/local/freeswitch/conf/sip_profiles/external/default_gw.xml

chkconfig mysqld on
service mysqld restart

mysqladmin -u root password root
ulimit -c unlimited
ulimit  -SHn  102400
sed -i "/* soft nofile /d" /etc/security/limits.conf
sed -i "/* hard nofile /d" /etc/security/limits.conf
echo "* soft nofile 102400">> /etc/security/limits.conf
echo "* hard nofile 102400">> /etc/security/limits.conf

mv /etc/sysctl.conf /home/sysctl_old.conf

echo 'net.ipv4.tcp_fin_timeout = 2
net.ipv4.tcp_tw_reuse = 1
net.ipv4.tcp_tw_recycle = 1
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_keepalive_time = 600
net.ipv4.ip_local_port_range = 4000 65000
net.ipv4.tcp_max_syn_backlog = 16384
net.ipv4.tcp_max_tw_buckets = 36000
net.ipv4.route.gc_timeout = 100
net.ipv4.tcp_syn_retries = 1
net.ipv4.tcp_synack_retries = 1
net.core.somaxconn = 16384
net.core.netdev_max_backlog = 16384
net.ipv4.tcp_max_orphans = 16384

'> /etc/sysctl.conf
sysctl -p

#删除 default provider
sed -i '/default_provider/d'  /usr/local/freeswitch/conf/vars.xml

sed -i '/outbound_caller_name=/d'  /usr/local/freeswitch/conf/vars.xml
sed -i 's/<\/include>/\n<X-PRE-PROCESS cmd=\"set\" data=\"outbound_caller_name=FSGUI\"\/>\n<\/include>/g'   /usr/local/freeswitch/conf/vars.xml

sed -i '/global_codec_prefs=/d'   /usr/local/freeswitch/conf/vars.xml
sed -i '/outbound_codec_prefs=/d'   /usr/local/freeswitch/conf/vars.xml
sed -i 's/<\/include>/\n<X-PRE-PROCESS cmd=\"set\" data=\"global_codec_prefs=PCMA,PCMU,G729,VP8,VP9,H264\"\/>\n<\/include>/g'   /usr/local/freeswitch/conf/vars.xml
sed -i 's/<\/include>/\n<X-PRE-PROCESS cmd=\"set\" data=\"outbound_codec_prefs=PCMA,PCMU,G729,VP8,VP9,H264\"\/>\n<\/include>/g'   /usr/local/freeswitch/conf/vars.xml

# change agent name
sed -i '/user-agent-string/d'  /usr/local/freeswitch/conf/sip_profiles/external.xml 
sed -i '/user-agent-string/d'  /usr/local/freeswitch/conf/sip_profiles/internal.xml 
sed -i 's/<\/settings>/\n<param name=\"username\" value=\"fsgui\"\/>\n<\/settings>/g'  /usr/local/freeswitch/conf/sip_profiles/internal.xml
sed -i 's/<\/settings>/\n<param name=\"username\" value=\"fsgui\"\/>\n<\/settings>/g'  /usr/local/freeswitch/conf/sip_profiles/external.xml
sed -i 's/<\/settings>/\n<param name=\"user-agent-string\" value=\"fsgui\"\/>\n<\/settings>/g'  /usr/local/freeswitch/conf/sip_profiles/internal.xml
sed -i 's/<\/settings>/\n<param name=\"user-agent-string\" value=\"fsgui\"\/>\n<\/settings>/g'  /usr/local/freeswitch/conf/sip_profiles/external.xml

sed -i '/inbound-late-negotiation/d'  /usr/local/freeswitch/conf/sip_profiles/external.xml 
sed -i '/inbound-zrtp-passthru/d'  /usr/local/freeswitch/conf/sip_profiles/external.xml 
sed -i '/idisable-transcoding/d'  /usr/local/freeswitch/conf/sip_profiles/external.xml 
sed -i 's/<\/settings>/\n<param name=\"inbound-late-negotiation\" value=\"false\"\/>\n<\/settings>/g'  /usr/local/freeswitch/conf/sip_profiles/external.xml
sed -i 's/<\/settings>/\n<param name=\"inbound-zrtp-passthru\" value=\"false\"\/>\n<\/settings>/g'  /usr/local/freeswitch/conf/sip_profiles/external.xml
sed -i 's/<\/settings>/\n<param name=\"idisable-transcoding\" value=\"false\"\/>\n<\/settings>/g'  /usr/local/freeswitch/conf/sip_profiles/external.xml

sed -i '/inbound-late-negotiation/d'  /usr/local/freeswitch/conf/sip_profiles/internal.xml 
sed -i '/inbound-zrtp-passthru/d'  /usr/local/freeswitch/conf/sip_profiles/internal.xml 
sed -i '/idisable-transcoding/d'  /usr/local/freeswitch/conf/sip_profiles/internal.xml 

sed -i 's/<\/settings>/\n<param name=\"inbound-late-negotiation\" value=\"false\"\/>\n<\/settings>/g'  /usr/local/freeswitch/conf/sip_profiles/internal.xml
sed -i 's/<\/settings>/\n<param name=\"inbound-zrtp-passthru\" value=\"false\"\/>\n<\/settings>/g'  /usr/local/freeswitch/conf/sip_profiles/internal.xml
sed -i 's/<\/settings>/\n<param name=\"idisable-transcoding\" value=\"false\"\/>\n<\/settings>/g'  /usr/local/freeswitch/conf/sip_profiles/internal.xml

# xml_curl 打开
sed -i '/mod_xml_curl/d'  /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml 
sed -i 's/<\/modules>/\n<load module=\"mod_xml_curl\"\/>\n<\/modules>/g'  /usr/local/freeswitch/conf/autoload_configs/modules.conf.xml

sed -i "/loglevel/d" /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
sed -i "/max-sessions/d" /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
sed -i "/sessions-per-second/d" /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
sed -i "/<\/settings>/d" /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
sed -i "/<\/configuration>/d" /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
echo "<param name=\"max-sessions\" value=\"4000\"/>" >>/usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
echo "<param name=\"sessions-per-second\" value=\"400\"/>" >>/usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
echo "<param name=\"loglevel\" value=\"INFO\"/>" >>/usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
sed -i "/rtp-start-port/d" /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
sed -i "/rtp-end-port/d" /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
echo "<param name=\"rtp-start-port\" value=\"15000\"/>"  >>/usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
echo "<param name=\"rtp-end-port\" value=\"25000\"/>" >>/usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
echo "</settings>" >>/usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
echo "</configuration>" >>/usr/local/freeswitch/conf/autoload_configs/switch.conf.xml
# 修改默认参数 /usr/local/freeswitch/conf/autoload_configs/switch.conf.xml 
# 修改默认参数2 /usr/local/freeswitch/conf/autoload_configs/logfile.conf.xml 
#<param name="maximum-rotate" value="32"/>
sed -i "s/32/5/g" /usr/local/freeswitch/conf/autoload_configs/logfile.conf.xml

#wget file.qzlink.com/bcg729.sh 
#sh bcg729.sh 1

#yum -y install mysql-connector-odbc

nohup sh /home/fsgui-api/fs_keeper.sh &
nohup sh /home/fsgui-api/api_keeper.sh &
nohup sh /home/tomcat/webapps/ROOT/WEB-INF/classes/tomcat_keeper.sh &

echo -e "\033[32;49;1m Congratulations, the FSGUI BPX has been installed successfully。\033[39;49;0m" 
echo -e "\033[32;49;1m ---------------------------------- \033[39;49;0m"
ServerIP=`cat getIP`
rm -rf getIP
echo -e "\033[32;49;1m 1 : http://$ServerIP:8080 \033[39;49;0m"
echo -e "\033[32;49;1m 2 : username:root\033[39;49;0m"
echo -e "\033[32;49;1m     password:root \033[39;49;0m"
echo -e "\033[32;49;1m ---------------------------------- \033[39;49;0m"
