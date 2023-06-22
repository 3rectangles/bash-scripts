[play@rundeck-mum-01 ~]$ cat /data/dist/scripts/addApplicationConfig.sh 
#!/bin/bash
BUILD_NO="$1"
PROJECT_NAME="$2"
CONF_FILE="$3"
BRANCH="$4"
VM_NAME="${PROJECT_NAME}-${BUILD_NO}"
ADMIN_PROJECT="payvoo-admin"
WEBAPP_PROJECT="payvoo-webapp"
echo $USER
mkdir /tmp/${VM_NAME}
cd /tmp/${VM_NAME}
PATH="conf/prod"

if [[ $PROJECT_NAME = $ADMIN_PROJECT ]] ;
then 
  PROJECT_NAME="payvoo-web"
  PATH="payvoo-admin/conf/prod"
fi


if [[ $PROJECT_NAME = $ADMIN_PROJECT ]] ;
then
  PROJECT_NAME="payvoo-web"
fi


#git archive --remote=ssh://git@bitbucket.org/financetech/${PROJECT_NAME}.git $BRANCH conf/logback.xml | tar -x
/bin/git archive --remote=ssh://git@bitbucket.org/financetech/${PROJECT_NAME}.git $BRANCH ${PATH}/${CONF_FILE} | /bin/tar -x

N1=`/bin/cat ${PATH}/${CONF_FILE} | /bin/wc -l`
#N2=` cat conf/logback.xml | wc -l`


if [ $N1 -eq 0 ] ;
then
    echo "couldn't fetch the configs"
    exit 1
fi


echo "job successfull" 

