PROJECT_NAME="$1"
VERSION="$2"

# List of allowed project names
spring_projects=("payvoo-lender")

mkdir -p /data/dist/${PROJECT_NAME}/${VERSION}/
cp /data/dist/builds/${PROJECT_NAME}-${VERSION}.zip /data/dist/${PROJECT_NAME}/${VERSION}/
cd /data/dist/${PROJECT_NAME}/${VERSION}/

# Check if project name is in the list of allowed projects
if [[ "${spring_projects[@]}" =~ "${PROJECT_NAME}" ]]; then
  # Move the zip file to a new path with a .jar extension
  CMD=`cp /data/dist/builds/${PROJECT_NAME}-${VERSION}.zip ${PROJECT_NAME}-${VERSION}.jar || { echo 'spring project Unzip failed !' ; exit 1; }`

  # Check if the move failed
  if [[ $CMD == *"Unzip failed"* ]]; then
    echo "Unzipping failed, will try again"
    CMD=`cp /data/dist/builds/${PROJECT_NAME}-${VERSION}.zip ${PROJECT_NAME}-${VERSION}.jar || { echo 'Unzip failed again!' ; exit 1; }`
    echo "$CMD"
  else
    echo "$CMD"
    echo "Command successful. Exiting script."
    exit 0
  fi
else
  echo "Project ${PROJECT_NAME} is not allowed. Aborting script."
  exit 1
fi


CMD=`unzip -u /data/dist/builds/${PROJECT_NAME}-${VERSION}.zip || { echo 'Unzip failed !' ; exit 1; }`
if [[ $CMD == *"Unzip failed"* ]]; then
	echo "Unzipping failed, will try again"
	CMD=`unzip -u /data/dist/builds/${PROJECT_NAME}-${VERSION}.zip || { echo 'Unzip failed again!' ; exit 1; }`
	echo "$CMD"
else
	echo "$CMD"
fi
#unzip -u ${PROJECT_NAME}-${VERSION}.zip

cd  ${PROJECT_NAME}-1.0-SNAPSHOT
chmod +x bin/${PROJECT_NAME}
echo "deployed ${PROJECT_NAME}-${VERSION}.zip and executable present at /data/dist/${PROJECT_NAME}/${VERSION}/${PROJECT_NAME}-1.0-SNAPSHOT/bin/${PROJECT_NAME}"


cd /data/dist/${PROJECT_NAME}/

VAR1=$(readlink current | cut -d'/' -f5)
echo $VAR1

cd /data/dist/scripts

#sh fire_logfile_change.sh ${PROJECT_NAME}  $VAR1
