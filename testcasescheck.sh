MACHINE="$1"
DBMAXID="$2"

cd /var/lib/jenkins/scripts/cs

if [ "$MACHINE" = "QA" ];
then
        echo "THIS BUILD IS FOR QA"
        sh qadump.sh
else
        echo "THIS BUILD IS FOR PROD"
	sh proddump.sh
fi
sleep 2

echo "dumps are ready"

TESTDB='mysql  -ubolt_dev -pbolt123 payvoo_test'
$TESTDB < /var/lib/jenkins/scripts/cs/csDumps/schema.sql
$TESTDB < /var/lib/jenkins/scripts/cs/csDumps/pedump.sql
sleep 2

VAR1=$($TESTDB <<< "select max(id) from play_evolutions where state='applied'" | sed 's/max(id)//g' | sed '/^[[:space:]]*$/d')
VAR2=$DBMAXID

echo $VAR1
echo $VAR2

if [ "$VAR1" = "$VAR2" ];
then
        echo "No new evloutions that needs to be run in payvoo_test in jenkins"
else
        cd /var/lib/jenkins/jobs/payvoo-credit-scoring/workspace/modules/payvoo-common/conf/evolutions/default
        COUNTER=$((VAR1+1))
        while [ $COUNTER -lt $((VAR2+1)) ]; do
                        TEMP=$(sed -n '/Ups/,/Downs/p' $COUNTER.sql | sed 's/-//g' | sed 's/#//g' | sed 's/!Ups//g' | sed 's/!Downs//g')
                        $TESTDB <<< "$TEMP"
                        COUNTER=$((COUNTER+1))
                done
fi
sleep 2

#cd /var/lib/jenkins/workspace/payvoo-credit-scoring
cd /var/lib/jenkins/jobs/payvoo-credit-scoring/workspace
mysql -u bolt_dev --password=bolt123 -Nse 'show tables' payvoo_test | while read table; do mysql -u bolt_dev --password=bolt123 -e "truncate table $table" payvoo_test;done

sleep 5

sbt "project root" test || { echo 'Test cases failed. Please check !' ; exit 1; }

[sc-460-user@jenkins-1 cs]$ 

