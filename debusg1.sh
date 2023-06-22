
echo "userId: $1 ,  timestamp: $2 , topic: $3 , Batch-size: $4 , Sleep-timer: $5 , feature: $6"

USER_ID=$1
TIMESTAMP=$2
TOPIC=$3
BATCH=$4
TIMER=$5
FEATURE=$6

if [[ "find-credit-limit" == $TOPIC ]] ; then
  echo "will not insert $TOPIC  row into mysql"
else
  echo "insert into user_topic_updates(user_id, topic, processing_version, created_at, updated_at ) values (${USER_ID}, '${TOPIC}', ${TIMESTAMP} , now(), now());" | mysql -ubolt_dev -pbolT\!234 -h 10.45.32.8 rebase_prod 
fi

EVENT_JSON=" \"userId\": ${USER_ID} , \"timestamp\": ${TIMESTAMP} , \"eventName\": \"${TOPIC}\""
if [[ ! -z "$FEATURE" ]] ; then
  EVENT_JSON=" $EVENT_JSON , \"feature\": \"${FEATURE}\""
fi
EVENT_JSON="{ $EVENT_JSON }"
echo $EVENT_JSON>>/tmp/user_sms_bt_data_json.txt
DEFAULT_KAFKA_OPTS=" --request-required-acks -1    --sync "

#cat /tmp/user_sms_bt_data_json.txt

counter=`cat /tmp/user_sms_bt_data_json.txt | wc -l`
echo "total lines $counter"
if [[ $counter -gt ${BATCH} ]];
then
echo "sending data to kafka" 
cat /tmp/user_sms_bt_data_json.txt  | /data/ext/kafka/bin/kafka-console-producer.sh ${DEFAULT_KAFKA_OPTS}  --broker-list kafka-broker-01.rebase.in:9092,kafka-broker-02.rebase.in:9092,kafka-broker-03.rebase.in:9092 --topic  ${TOPIC} 
> /tmp/user_sms_bt_data_json.txt
echo "sleep for ${TIMER}seconds"
sleep ${TIMER}

fi
