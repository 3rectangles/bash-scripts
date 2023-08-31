
PROJECT_NAME="$1" 
BUILD_NUMBER="$2" 

## If BUILD_NUMBER is 0, it means start from BUILD_NUMBEr symlinked from "current"
SUBPATH="${BUILD_NUMBER}/${PROJECT_NAME}-1.0-SNAPSHOT"; 
#if [ $BUILD_NUMBER = "0" ]; then
 # SUBPATH="current"
#fi
declare -a builds
cd /data/dist/${PROJECT_NAME}/
find -maxdepth 1 -iname "*[0-9]" | cut -c 3- > builds.txt
#cat builds.txt

while IFS="," read -r build
do 
   SUBPATH="${build}/${PROJECT_NAME}-1.0-SNAPSHOT";
   cd /data/dist/${PROJECT_NAME}/${SUBPATH}
   if [ -f RUNNING_PID ]; then
   APP_PID=`cat RUNNING_PID`
   kill -9 ${APP_PID}
   sleep 2
   echo "killed the pid ${APP_PID}"
else
   echo "RUNNING_PID file is not present, ${PROJECT_NAME}  doesn't seem to be running"
fi
if [ -f RUNNING_PID ]; then
   rm RUNNING_PID
   echo "also removed the RUNNING_PID file"
fi

done < builds.txt
## If the RUNNING_PID file is present, use the pid in it to kill the running process


SUBPATH="current"
cd /data/dist/${PROJECT_NAME}/$SUBPATH


if [ -f RUNNING_PID ]; then
   APP_PID=`cat RUNNING_PID`
   kill -9 ${APP_PID}
   sleep 2
   echo "killed the pid ${APP_PID}"
else
   echo "RUNNING_PID file is not present, ${PROJECT_NAME}  doesn't seem to be running"
fi 
if [ -f RUNNING_PID ]; then
   rm RUNNING_PID
   echo "also removed the RUNNING_PID file"
fi
