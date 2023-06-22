TABLE=$2
DATASET=$1
 
DEFAULT_KAFKA_OPTS=" --request-required-acks -1  --sync "




gcloud auth activate-service-account 19523251995-compute@developer.gserviceaccount.com   --key-file=$GOOGLE_APPLICATION_CREDENTIALS  --project=intense-nexus-126408

bq --project_id=intense-nexus-126408 --location=asia-south1 extract --destination_format=CSV ${DATASET}.${TABLE} gs://testbucket-amit/fcl_files/${TABLE}-*.csv

rm -rf /tmp/${TABLE}
mkdir /tmp/${TABLE}

gsutil cp gs://testbucket-amit/fcl_files/${TABLE}-*.csv /tmp/${TABLE}/

for file in ls /tmp/${TABLE}/; do
  for uid in cat /tmp/${TABLE}/${file} | tr -d '\r'; do
    sh /data/dist/scripts/fire_event.sh  ${uid} date +%s666 find-credit-limit
  done
done







cat /tmp/temp_user_data_json.txt | /data/ext/kafka/bin/kafka-console-producer.sh ${DEFAULT_KAFKA_OPTS}  --broker-list  kafka-broker-01.rebase.in:9092,kafka-broker-02.rebase.in:9092,kafka-broker-03.rebase.in:9092 --topic find-credit-limit  
> /tmp/temp_user_data_json.txt

