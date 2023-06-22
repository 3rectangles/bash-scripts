#!/bin/bash 

PROJECT_NAME="$1" 
BUILD_NUMBER="$2" 
HTTP_PORT="$3"
HTTPS_PORT="$4"
VERBOSE="$5"
## If BUILD_NUMBER is 0, it means start from BUILD_NUMBEr symlinked from "current"
SUBPATH="${BUILD_NUMBER}/${PROJECT_NAME}-1.0-SNAPSHOT"; 
if [ $BUILD_NUMBER = "0" ]; then
  SUBPATH="current"
fi

cd /data/dist/${PROJECT_NAME}/${SUBPATH}
echo "mayank" > text.txt
if [ -f RUNNING_PID ]; then
  echo "RUNNING_PID file is present, service ${PROJECT_NAME} might be running, please stop it first"
  exit 1
fi
mv logs/application.log logs/application.log.`date +%Y%m%d_%H%M`

HTTP_CONFIG="-Dhttp.port=${HTTP_PORT}"
PORT_CHECK="${HTTP_PORT}"
if [ "${HTTPS_PORT}" -gt "8000" ] ; then
  HTTP_CONFIG="${HTTP_CONFIG} -Dhttps.port=${HTTPS_PORT}"
  PORT_CHECK="${HTTPS_PORT}"
fi

echo "${PROJECT_NAME}: config ${HTTP_CONFIG} PORT_CHECK: ${PORT_CHECK}"

if [ $PROJECT_NAME = "payvoo-admin" ]; then
JMX_OPTS=" -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9118 -Dcom.sun.management.jmxremote.local.only=true "
JMX_OPTS=" ${JMX_OPTS} -Dcom.sun.management.jmxremote.authenticate=false -Dcom.sun.management.jmxremote.ssl=false -Djava.rmi.server.hostname=127.0.0.1 "
fi

#START_CMD="bin/${PROJECT_NAME} ${JMX_OPTS}  -J-server -J-Xms1G -J-Xmx3584M  -Dconfig.file=/data/dist/${PROJECT_NAME}/production.conf -Dlogger.file=/data/dist/${PROJECT_NAME}/logback.xml ${HTTP_CONFIG}  -Dregex_type.file=regex_type.properties -Dregex_config.file=regex_config.properties  "

START_CMD="bin/${PROJECT_NAME} ${JMX_OPTS}  -J-server -J-Xms1G -J-Xmx5G  -Dconfig.file=/data/dist/${PROJECT_NAME}/production.conf -Dlogger.file=/data/dist/${PROJECT_NAME}/logback.xml ${HTTP_CONFIG}  -Dregex_type.file=regex_type.properties -Dregex_config.file=regex_config.properties  "

echo ${START_CMD}
nohup ${START_CMD} > /dev/null 2>&1 & 

sleep 2

##tail -f logs/application.log | while read LOGLINE
##do
##   [[ "$VERBOSE" != "0" ]] &&  echo $LOGLINE
##   [[ "${LOGLINE}" == *"Listening for HTTP"* ]] && pkill -P $$ tail
##done

TEXT_TO_FIND="Listening for HTTP"
LINES_FOUND="0"
while [ "x${LINES_FOUND}" == "x0" ]
do  sleep  2
  LINES_FOUND=$(grep -c "${TEXT_TO_FIND}" logs/application.log)
  echo "LINES_FOUND: ${LINES_FOUND}"
done

sleep 2
echo "curl -L -v -s  -m 30 http://localhost:${PORT_CHECK}/"
curl -L -v -s  -m 30 http://localhost:${PORT_CHECK}/health

echo "service ${PROJECT_NAME} start: SUCCESS"
exit 0
