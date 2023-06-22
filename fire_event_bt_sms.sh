echo "userId: $1 ,  timestamp: $2 , topic: $3 , feature: $4"

USER_ID=$1
TIMESTAMP=$2
TOPIC=$3
FEATURE=$4

if [[ "find-credit-limit" == $TOPIC ]]; then
  echo "will not insert $TOPIC row into mysql"
else
  echo "insert into user_topic_updates(user_id, topic, processing_version, created_at, updated_at) values (${USER_ID}, '${TOPIC}', ${TIMESTAMP}, now(), now());" | mysql -ubolt_dev -pbolT\!234 -h 10.45.32.8 rebase_prod 
fi

EVENT_JSON="{\"userId\": ${USER_ID}, \"timestamp\": ${TIMESTAMP}, \"eventName\": \"${TOPIC}\""
if [[ ! -z "$FEATURE" ]]; then
  EVENT_JSON="${EVENT_JSON}, \"feature\": \"${FEATURE}\""
fi
EVENT_JSON="${EVENT_JSON}}"
echo $EVENT_JSON | /data/ext/kafka/bin/kafka-console-producer.sh --request-required-acks -1 --sync --broker-list kafka-broker-01.rebase.in:9092,kafka-broker-02.rebase.in:9092,kafka-broker-03.rebase.in:9092 --topic $TOPIC 

