#!/bin/bash

INSTANCE_NAME="rebase01"
PROJECT_ID="smartcoin-dev-test"
CURRENT_DATE=$(date +'%Y-%m-%dT%H:%M:%SZ')
DESCRIPTION="Backup for ${INSTANCE_NAME} on ${CURRENT_DATE}"
STATUS="SUCCESSFUL"

LAST_BACKUP_TIME=$(gcloud sql backups list --instance - --project=${PROJECT_ID} --format="table(id, window_start_time, status, instance, description)" --sort-by=-window_start_time | grep ${INSTANCE_NAME} | grep ${STATUS} | head -n 1 | awk '{ print $2 }')

# Convert times to Unix timestamps
timestamp1=$(date -u -d "${CURRENT_DATE}" +"%s")
timestamp2=$(date -u -d "${LAST_BACKUP_TIME}" +"%s")

# Calculate the difference in seconds
time_diff=$((timestamp1 - timestamp2))

# Calculate the time difference in hours
time_diff_hours=$(( time_diff/3600))

if [ $time_diff_hours -lt 4 ]; then
  echo "The backup is less than 4 hours old."
else
  gcloud sql backups create --async --instance=${INSTANCE_NAME} --project=${PROJECT_ID} --description="${DESCRIPTION}"
  if [ $? -eq 0 ]; then
    echo "Backup taken successfully."
  fi
fi
