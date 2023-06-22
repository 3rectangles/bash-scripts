configFile=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/configFile" -H "Metadata-Flavor: Google")
loggingFile=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/loggingFile" -H "Metadata-Flavor: Google")

echo "${configFile}">>/data/dist/payvoo-notification/production.conf
echo "${loggingFile}" >>/data/dist/payvoo-notification/logback.xml
echo 'common-utils.kafka.default.servers="10.190.0.41:9092,10.190.0.42:9092,10.190.0.43:9092"' >> /data/dist/payvoo-notification/production.conf 
sudo -H -u play bash -c 'echo "export MYSQL_IP=10.180.0.3">>~/.bashrc && source ~/.bashrc && source /data/dist/scripts/secret-manager.sh payvoo-notification >>/data/logs/secret.log && sh /data/dist/scripts/start_app.sh payvoo-notification 0 9019 disable 0 ' 