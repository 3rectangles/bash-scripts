#!/bin/bash

# authenticate with service account
#gcloud auth activate-service-account --key-file=path/to/keyfile.json

# set variables for source and destination projects, datasets, and tables
src_project=$1
src_dataset=$2
src_table=$3
dst_project=$4
dst_dataset=$5
dst_table=$6



# check if source dataset exists
if  bq ls "$src_dataset" |grep -c "Not found: Dataset" > 0; then
  echo "Error: Source dataset does not exist."
  exit 1
fi


# check if destination dataset exists
if  bq ls "$dst_dataset" |grep -c "Not found: Dataset" > 0; then
  # create destination dataset if it does not exist
  bq --location=asia-south1 mk --dataset "$dst_dataset"
  
fi

# copy the table from the source project to the destination project
if bq cp "$src_project:$src_dataset.$src_table" "$dst_project:$dst_dataset.$dst_table"; then
  echo "Table sync successful!"
else
  echo "Error: Table sync failed."
  exit 1
fi
