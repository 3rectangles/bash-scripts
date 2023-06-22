
PROJECT_NAME="$1" 
BUILD_NUMBER="$2" 


spring_projects=("payvoo-lender")


if [ $PROJECT_NAME = "0" ]; then
  echo "projectName must be specified ..."
fi
if [ $BUILD_NUMBER = "0" ]; then
  echo "buildNumber must be specified ..."
fi


if [[ " ${spring_projects[@]} " =~ " ${PROJECT_NAME} " ]]; then
  SUBPATH="${BUILD_NUMBER}/"
else
  SUBPATH="${BUILD_NUMBER}/${PROJECT_NAME}-1.0-SNAPSHOT"
fi


cd /data/dist/${PROJECT_NAME}/
ln -snf `readlink -f current` previous
ln -snf /data/dist/${PROJECT_NAME}/${SUBPATH} /data/dist/${PROJECT_NAME}/current

echo "changed the symlinks:"
ls -l previous current
