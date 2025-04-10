#!/bin/bash

export JRE_HOME=<PATH_TO_JRE>
cd /opt/tomcat-aeps/bin/
sh shutdown.sh
pids=$(ps -ef | grep tomcat-aeps | grep -v "grep" | awk '{print $2}')
for pid in ${pids[@]}; do
        echo "killing process $pid"
        kill -9 $pid
        echo "killed process $pid"
done
#echo "killed process $pids"
rm -rf ../webapps/aeps ../webapps/aeps.war
wget <URL_FROM_WHERE_BUILD_WILL_BE_DOWNLOADED> -O ../webapps/build.war

# eg., wget https://eb77-115-247-182-238.ngrok-free.app/build.war -O ../webapps/build.war

sh startup.sh
tail -500f /opt/tomcat-aeps/logs/catalina.out
