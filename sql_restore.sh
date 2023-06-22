#!/bin/bash

SOURCE_INSTANCE_NAME="rebase01"
TARGET_INSTANCE_NAME="test1"
PROJECT_ID="smartcoin-dev-test"
BACKUP_ID="1687176903790"


gcloud sql backups restore $BACKUP_ID   --restore-instance=$TARGET_INSTANCE_NAME  --backup-instance=$SOURCE_INSTANCE_NAME   --project=$PROJECT_ID
