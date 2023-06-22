configFile=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/configFile" -H "Metadata-Flavor: Google")
loggingFile=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/loggingFile" -H "Metadata-Flavor: Google")
startapplication=$(curl "http://metadata.google.internal/computeMetadata/v1/instance/attributes/startapplication" -H "Metadata-Flavor: Google")

echo "${configFile}">/data/dist/payvoo-lender/production.conf
echo "${loggingFile}" >/data/dist/payvoo-lender/logback.xml
echo "${startapplication}" >/data/dist/scripts/start_application.sh
mkdir /data/logs
chown play:play /data/logs
chown play:play /data/dist/payvoo-lender/production.conf;
chown play:play /data/dist/payvoo-lender/logback.xml;
chown play:play /data/dist/scripts/start_application.sh;

sudo -H -u play bash -c 'echo "export DEFAULT_DB_IP=10.45.32.8">>~/.bashrc && source ~/.bashrc' 
sudo -H -u play bash -c 'echo "export DEFAULT_DB_NAME=rebase_lender">>~/.bashrc && source ~/.bashrc' 
sudo -H -u play bash -c 'echo "export READONLY_DB_IP=10.45.32.8">>~/.bashrc && source ~/.bashrc' 
sudo -H -u play bash -c 'echo "export READONLY_DB_NAME=rebase_lender">>~/.bashrc && source ~/.bashrc' 
sudo -H -u play bash -c 'echo "export KAFKA_SERVERS=kafka-broker-01.rebase.in:9092,kafka-broker-02.rebase.in:9092,kafka-broker-03.rebase.in:9092">>~/.bashrc && source ~/.bashrc' 
sudo -H -u play bash -c 'echo "export KAFKA_LP_SERVERS=10.176.254.9:9092,10.176.254.10:9092,10.176.254.13:9092">>~/.bashrc && source ~/.bashrc' 
sudo -H -u play bash -c 'echo "export REDIS_HOST=10.176.249.2">>~/.bashrc && source ~/.bashrc' 
sudo -H -u play bash -c 'echo "export REDIS_CLUSTER_HOST=10.176.249.3">>~/.bashrc && source ~/.bashrc' 
sudo -H -u play bash -c 'echo "export service=payvoo-lender">>~/.bashrc && source ~/.bashrc' 
sudo -H -u play bash -c 'echo "export EMAIL_SERVICE_URL="https://notification.smartcoin.co.in"">>~/.bashrc && source ~/.bashrc' 
sudo -H -u play bash -c 'echo "export SERVICE_NAME=lender_service">>~/.bashrc && source ~/.bashrc' 



sudo service filebeat start
sudo service vector start



sudo -H -u play bash -c 'source ~/.bashrc && sh /data/dist/scripts/start_app.sh payvoo-lender 0 9020 disable 0'
sudo service filebeat start
