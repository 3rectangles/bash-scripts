#!/bin/bash

# Assign the credentials to a variable
PROD_DB_CRED="-ubolt_dev -pbolT123 --host 10.180.0.3 rebase_qa09"
# Check if all arguments were provided
if [ $# -ne 3 ]; then
    echo "Please provide the following arguments in this order: TABLE_NAME, FILE_NAME_TO_BE_SAVED, USER_IDS"
    exit 1
fi

# Assign arguments to variables
TABLE_NAME=$1
FILE_NAME_TO_BE_SAVED=$2
USER_IDS=$3

# Build mysqldump command and execute it
mysqldump $PROD_DB_CRED --set-gtid-purged=OFF --no-create-info --insert-ignore $TABLE_NAME --where="user_id in ($USER_IDS)" > /tmp/$FILE_NAME_TO_BE_SAVED.sql

# Check if the command was successful
if [ $? -eq 0 ]; then
    echo "Data from $TABLE_NAME  was exported to /tmp/$FILE_NAME_TO_BE_SAVED.sql"
else
    echo "An error occurred while exporting data from $TABLE_NAME"
    exit 1
fi
