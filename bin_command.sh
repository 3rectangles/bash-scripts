bin/payvoo-notification -Dcom.sun.management.jmxremote -Dcom.sun.management.jmxremote.port=9118 -Dcom.sun.management.jmxremote.local.only=true  -J-server -J-Xms1G -J-Xmx5G  -Dconfig.file=/data/dist/payvoo-notification/production.conf -Dlogger.file=/data/dist/payvoo-notification/logback.xml -Dhttp.port=9019  -Dregex_type.file=regex_type.properties -Dregex_config.file=regex_config.properties



sudo -H -u play bash /data/dist/scripts/start_app.sh payvoo-notification 0 9019 disable 0




PROJECT_NAME="$1" 
BUILD_NUMBER="$2" 
HTTP_PORT="$3"
HTTPS_PORT="$4"
VERBOSE="$5"


 http congif = -Dhttp.port=9019