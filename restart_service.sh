#!/bin/bash

# Define the paths and commands
cron_file="/var/spool/cron/play"
cron_backup="/var/spool/cron/play.bkp"
cron_commented_job="*/5 * * * * bash /data/dist/scripts/auto_restart.sh payvoo-admin"
restart_command="/bin/bash /data/dist/scripts/stop_app.sh payvoo-admin 0 && /bin/bash /data/dist/scripts/start_app.sh payvoo-admin 0 9011 0 1"
verification_command="curl -s -o /dev/null -w '%{http_code}' -m 5 localhost:${port}"
project_name="payvoo-admin"
port=9011

# Step 1: Backup the original cron file
if [ -f "$cron_file" ]; then
  cp "$cron_file" "$cron_backup"
  echo "Original cron file backed up to $cron_backup"
else
  echo "Original cron file not found. Exiting."
  exit 1
fi

# Step 2: Comment out the specific cron job
sed -i "/$cron_commented_job/s/^/#/" "$cron_file"
echo "Commented out the specified cron job."

# Step 3: Restart the service
echo "Restarting the service..."
eval "$restart_command"

# Verification: Verify if the service restart was completed
CURL=$(eval "$verification_command")
if [ "$CURL" -ne 303 ]; then
  echo "Service is not running, going to restart service..."
  eval "/bin/bash /data/dist/scripts/stop_app.sh $project_name 0 && /bin/bash /data/dist/scripts/start_app.sh $project_name 0 9011 0 1"
  sh /data/dist/customize_scripts/jvm-restart.sh >> /data/logs/metric.log
else
  echo "Service restart verified."
fi

# Cleanup: Remove the cron backup
rm -f "$cron_backup"
echo "Removed the cron backup file."

# Trap: Restore the original cron file on exit
cleanup() {
  if [ -f "$cron_backup" ]; then
    cp "$cron_backup" "$cron_file"
    echo "Restored the original cron file from backup."
  else
    echo "Cron backup not found. Please restore the cron file manually."
  fi
}
trap cleanup EXIT

echo "Script completed successfully."
