#!/bin/bash

INSTANCE_NAME="rebase01"
PROJECT_ID="smartcoin-dev-test"
CURRENT_DATE=$(date +'%Y-%m-%dT%H:%M:%SZ')

# Convert current date to Unix timestamp
CURRENT_TIMESTAMP=$(date -u -d "${CURRENT_DATE}" +"%s")

# Find all on-demand backups for the instance
BACKUPS=$(gcloud sql backups list --instance=${INSTANCE_NAME} --project=${PROJECT_ID} --filter="type:ON_DEMAND" --format="table(id, window_start_time)")



BACKUPS=$(echo "$BACKUPS" | sed '1d')

# Loop through each backup
while read -r line; do
  # Extract backup ID and start time
  BACKUP_ID=$(echo "$line" | awk '{print $1}')
  BACKUP_TIME=$(echo "$line" | awk '{print $2}')
#  echo $line

  # Convert backup time to Unix timestamp
  BACKUP_TIMESTAMP=$(date -u -d "${BACKUP_TIME}" +"%s")

  # Calculate the difference in seconds
  BACKUP_AGE=$((CURRENT_TIMESTAMP - BACKUP_TIMESTAMP))

  # Calculate the age difference in days with floating-point arithmetic
  BACKUP_AGE_DAYS=$(echo "scale=2; $BACKUP_AGE / 86400" | bc)

  # Delete the backup if it is older than 3 days
  if (( $(echo "$BACKUP_AGE_DAYS > 3" | bc -l) )); then
    echo "Deleting backup with ID ${BACKUP_ID} and start time ${BACKUP_TIME} as it is ${BACKUP_AGE_DAYS} days old."
    gcloud sql backups delete ${BACKUP_ID} --instance=${INSTANCE_NAME} --project=${PROJECT_ID} --quiet

    # Check if the deletion was successful
    if [ $? -eq 0 ]; then
      echo "Backup with ID ${BACKUP_ID} and start time ${BACKUP_TIME} has been successfully deleted."
    else
      echo "Failed to delete backup with ID ${BACKUP_ID} and start time ${BACKUP_TIME}."
    fi
  fi
done <<< "$BACKUPS"