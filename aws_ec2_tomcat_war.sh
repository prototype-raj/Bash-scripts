#!/bin/bash

# This is a simple script to automate the deploying process of a war file in a tomcat server from a remote location.

cd /opt/tomcat/bin/
sh shutdown.sh
pids=$(ps -ef | grep tomcat | grep -v "grep" | awk '{print $2}')
for pid in ${pids[@]}; do
        echo "killing process $pid"
        kill -9 $pid
        echo "killed process $pid"
done
#echo "killed process $pids"
rm -rf ../webapps/war_name ../webapps/war_name.war
wget http://x.x.x.x/y/war_name.war -O ../webapps/war_name.war

# eg., wget https://eb77-115-247-182-238.ngrok-free.app/build.war -O ../webapps/build.war

sh startup.sh
tail -500f /opt/tomcat/logs/catalina.out
