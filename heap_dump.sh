
#!/bin/bash

# Parameters
project_name="$1"
threshold=85
dump_dir="/data/dist/${project_name}/dump"

# Create the dump directory if it doesn't exist
mkdir -p "$dump_dir" > /dev/null 2>&1

# Get the PID of the project
pid=$(ps -ef | grep -Ew "/data/dist/${project_name}" | grep -v grep | awk '{print $2}')

# Check if the project's process is running
if [ -z "${pid}" ]; then
  echo "Process for ${project_name} not found. Exiting..."
  exit 0
fi

# Get the latest .hprof file in the directory
latest_hprof_file=$(ls -t "${dump_dir}"/*.zip 2>/dev/null | head -n 1)

# Check if a .hprof file exists
if [ -n "${latest_hprof_file}" ]; then
  file_timestamp_date=$(echo "${latest_hprof_file=}" | awk -F'.' '{print $1}' | awk -F'-' '{print $NF}' | awk -F'_' '{print $1}')
  # Get the current timestamp
  current_timestamp=$(date +%Y%m%d)

  # Check if the file belongs to the same day
  if [ "${file_timestamp_date}" == "${current_timestamp}" ]; then
    echo "Dump file for today already exists. Exiting..."
    exit 0
  fi
fi

# Create a timestamp for today's date and file name
today=$(date +%Y%m%d_%H%S)
file_name="${project_name}-$(hostname)-${pid}-${today}"

# Get CPU and memory usage of the project
cpu_usage=$(ps -p "$pid" -o %cpu | tail -n 1)
memory_usage=$(ps -p "$pid" -o %mem | tail -n 1)


# Check if memory usage exceeds the threshold
if (( $(echo "${memory_usage} >= ${threshold}" | bc -l) )); then
  # Generate heap dump using jcmd
  /data/ext/java/bin/jcmd "${pid}" GC.heap_dump -all "${dump_dir}/${file_name}.hprof"

  # Generate thread dump using jcmd
  /data/ext/java/bin/jcmd "${pid}" Thread.print > "${dump_dir}/${file_name}-thread.dump"


  # Create a zip file
  zip_name="${project_name}-$(hostname)-${pid}-${today}.zip"
  zip -r "${dump_dir}/${zip_name}" "${dump_dir}/${file_name}.hprof" "${dump_dir}/${file_name}-thread.dump"
  # Delete the heap dump and thread dump files
 rm "${dump_dir}/${file_name}.hprof" "${dump_dir}/${file_name}-thread.dump"

  # Copy the zip file to Google Cloud Storage
  gsutil cp "${dump_dir}/${zip_name}" gs://jenkins_stage_builds/dump/


  echo "Heap dump and thread dump created at $(date)."
else
  echo "Memory usage is below the threshold at $(date). No dump created."
fi




sudo vim /data/dist/scripts/heap_snapshot.sh


sudo chown play:play /data/dist/scripts/heap_snapshot.sh && sudo chmod 777 /data/dist/scripts/heap_snapshot.sh

ll /data/dist/scripts/heap_snapshot.sh


crontab -e

#manually: add-heap-dump
* * * * * sh /data/dist/scripts/heap_snapshot.sh payvoo-admin  >>/data/logs/heapzip.log


#manually: delete  heap log

*/5 * * * * rm /data/logs/heapzip.log
