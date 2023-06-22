#!/bin/bash

# Set variables for the project, dataset, and table
project=$1
dataset=$2
table=$3

# Set variables for the bucket name, folder, and dump file name
bucket_name=my-bucket
folder=dump-files
dump_file=dump.avro

# Check if the project, dataset, and table exist
if bq ls $project > /dev/null 2>&1; then
  if bq ls $project:$dataset > /dev/null 2>&1; then
    if bq ls $project:$dataset.$table > /dev/null 2>&1; then
      # Dump the table in Avro format and store it in the bucket
      bq extract --destination_format=AVRO $project:$dataset.$table gs://$bucket_name/$folder/$dump_file
      echo "Table $project:$dataset.$table dumped to gs://$bucket_name/$folder/$dump_file in Avro format."
    else
      echo "Table $project:$dataset.$table does not exist."
    fi
  else
    echo "Dataset $project:$dataset does not exist."
  fi
else
  echo "Project $project does not exist."
fi
