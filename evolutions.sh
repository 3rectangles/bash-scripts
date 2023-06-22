PROJECT_NAME="$1"
MACHINE="$2"
TESTCASESCHECK="$3"

cd  ${PROJECT_NAME}
#VAR1=$(awk NR==63 README) #( tail -n 2 README )
VAR1=$(tail -n 1 README)

if [ "$MACHINE" = "-" ];
then
	echo "please select a machine!!"
	exit 1
else
	echo "selected machine is : $MACHINE"
fi

source ~/.bashrc

if [ "$MACHINE" = "STAGE" ];
then
	echo "THIS BUILD IS FOR STAGE"
	DBNAME=" rebase_stage"
	dblink=$(printenv QACRED)$DBNAME
elif [ "$MACHINE" = "QA02" ];
then
	echo "THIS BUILD IS FOR QA02"
        DBNAME=" rebase_qa02"
        dblink=$(printenv QACRED)$DBNAME
elif [ "$MACHINE" = "QA03" ];
then
        echo "THIS BUILD IS FOR QA02"
        DBNAME=" rebase_qa03"
        dblink=$(printenv QACRED)$DBNAME
elif [ "$MACHINE" = "QA04" ];
then
        echo "THIS BUILD IS FOR QA02"
        DBNAME=" rebase_qa04"
        dblink=$(printenv QACRED)$DBNAME
elif [ "$MACHINE" = "QA05" ];
then
        echo "THIS BUILD IS FOR QA05"
        DBNAME=" rebase_qa05"
        dblink=$(printenv QACRED)$DBNAME
elif [ "$MACHINE" = "QA06" ];
then
        echo "THIS BUILD IS FOR QA06"
        DBNAME=" rebase_qa06"
        dblink=$(printenv QACRED)$DBNAME
elif [ "$MACHINE" = "QA07" ];
then
        echo "THIS BUILD IS FOR QA08"
        DBNAME=" rebase_qa07"
        dblink=$(printenv QACRED)$DBNAME


elif [ "$MACHINE" = "QA08" ];
then
        echo "THIS BUILD IS FOR QA08"
        DBNAME=" rebase_qa08"
        dblink=$(printenv QACRED)$DBNAME


elif [ "$MACHINE" = "QA09" ];
then
        echo "THIS BUILD IS FOR QA09"
        DBNAME=" rebase_qa09"
        dblink=$(printenv QACRED)$DBNAME


elif [ "$MACHINE" = "QA10" ];
then
        echo "THIS BUILD IS FOR QA10"
        DBNAME=" rebase_qa10"
        dblink=$(printenv QACRED)$DBNAME
elif [ "$MACHINE" = "QA11" ];
then
        echo "THIS BUILD IS FOR QA11"
        DBNAME=" rebase_qa11"
        dblink=$(printenv QACRED)$DBNAME
elif [ "$MACHINE" = "QA12" ];
then
        echo "THIS BUILD IS FOR QA02"
        DBNAME=" rebase_qa12"
        dblink=$(printenv QACRED)$DBNAME
elif [ "$MACHINE" = "QA13" ];
then
        echo "THIS BUILD IS FOR QA02"
        DBNAME=" rebase_qa13"
        dblink=$(printenv QACRED)$DBNAME
elif [ "$MACHINE" = "QA14" ];
then
        echo "THIS BUILD IS FOR QA02"
        DBNAME=" rebase_qa14"
        dblink=$(printenv QACRED)$DBNAME
elif [ "$MACHINE" = "QA21" ];
then
        echo "THIS BUILD IS FOR QA21"
        DBNAME=" rebase_qa21"
        dblink=$(printenv QACRED)$DBNAME
else
	echo "THIS BUILD IS FOR PROD"
	dblink=$(printenv PRODCRED)
fi
sleep 2

cd /var/lib/jenkins/scripts

VAR2=$($dblink <<< "select max(id) from play_evolutions" | sed 's/max(id)//g' | sed '/^[[:space:]]*$/d')
STATE=$($dblink <<< "select state from play_evolutions where id = $VAR2" | sed 's/state//g' | sed '/^[[:space:]]*$/d')

#sh cleanCS.sh

echo "code evoltion: $VAR1"
echo "db evoltion: $VAR2"
echo "evolution state: $STATE"

#if [ "$VAR1" = "$VAR2" ] 
#then
	if [ "$STATE" = "applied" ]
	then
		echo "evolutions match and in correct state. PROCEED!"
		if [ "$TESTCASESCHECK" = "YES" ]
		then
			if [ "$MACHINE" = "STAGE" ] || [ "$MACHINE" = "QA02" ] || [ "$MACHINE" = "QA03" ] || [ "$MACHINE" = "QA04" ] || [ "$MACHINE" = "QA05" ] || [ "$MACHINE" = "QA07" ]  || [ "$MACHINE" = "QA08" ] || [ "$MACHINE" = "QA09" ] || [ "$MACHINE" = "QA10" ]  || [ "$MACHINE" = "QA11" ] || [ "$MACHINE" = "QA06" ]|| [ "$MACHINE" = "QA12" ] || [ "$MACHINE" = "QA13" ] || [ "$MACHINE" = "QA14" ] || [ "$MACHINE" = "QA21" ];
			then
       				echo "THIS BUILD IS FOR QA SO NO TESTCASES CHECK"       				
			elif [ "$VAR1" = "$VAR2" ];
			then
        			echo "THIS BUILD IS FOR PROD AND EVOLUTION ALSO MATCHES SO TESTCASES WILL BE CHECKED"
				sh /var/lib/jenkins/scripts/cs/testcasescheckCS.sh "$MACHINE" "$VAR1" || { echo 'Test cases Failed'; exit 1;}
			else
				echo "evolution conflict. please check and deploy common. ABORTING MISSION!"
                                exit 1
			fi
		else
			echo "TESTCASESCHECK is disabled"
		fi
	else
		if [ "$TESTCASESCHECK" = "YES" ]
		then
			echo "TESTCASESCHECK is enabled"
			#sh testcasescheckCS.sh "$MACHINE" "$VAR1" || { echo 'Test cases Failed'; exit 1;}
			echo "TESTCASECHECK is done"
		else
			echo "TESTCASESCHECK is disabled"
		fi
		echo "evolutions match but in incorrect state. ABORTING MISSION!"
		exit 1
	fi
#else
		#if [ "$TESTCASESCHECK" = "YES" ]
	#	then
	#		echo "TESTCASESCHECK is enabled"
	#		#sh testcasescheckCS.sh "$MACHINE" "$VAR1" || { echo 'Test cases Failed'; exit 1;}
	#		echo "TESTCASECHECK is done"
	#	else
	#		echo "TESTCASESCHECK is disabled"
	#	fi
        #echo "evolution conflict. please check and deploy common. ABORTING MISSION!"
        #exit 1
#fi
