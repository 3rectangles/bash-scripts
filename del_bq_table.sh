#!/bin/bash

# authenticate with service account
#gcloud auth activate-service-account --key-file=path/to/keyfile.json

# set variables for source and destination projects, datasets, and tables
src_project=$1
src_dataset=$2
src_table=$3
dst_dataset="${src_dataset}_backup"
dst_table="${src_table}_backup"


allowed_dataset=("Marketing_KPI" )

# check if source dataset exists in the hardcoded list


if [[ ! " ${allowed_dataset[@]} " =~ " ${src_dataset} " ]]; then
    echo "src_dataset is NOT in the list of allowed_dataset"
    exit 1
fi


# check if source dataset exists in bq 
if  bq ls "$src_project:$src_dataset" |grep -c "Not found: Dataset" > 0; then
  echo "Error: Source dataset does not exist."
  exit 1
fi



# check if destination dataset exists
if  bq ls "$src_project:$dst_dataset" |grep -c "Not found: Dataset" > 0; then
  # create destination dataset if it does not exist
  bq --location=asia-south1 mk --dataset "$src_project:$dst_dataset"
  
fi

# copy the table from the source dataset to the destination dataset
if bq cp -f "$src_project:$src_dataset.$src_table" "$src_project:$dst_dataset.$dst_table"; then
  echo "Table copied to backup dataset successfully!"
else
  echo "Error: Table copy to backup dataset failed."
  exit 1
fi

# delete the original table if backup successful
if bq rm -f "$src_project:$src_dataset.$src_table"; then
  echo "Original table deleted successfully!"
else
  echo "Error: Original table deletion failed."
  exit 1
fi
