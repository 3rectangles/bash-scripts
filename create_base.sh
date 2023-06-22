#!/bin/bash
PROJECT_NAME="$1"
BUILD_NO="$2"
#SERVICE_ACCOUNT="$3"
STARTUP_SCRIPT_FILE="/data/dist/scripts/vm-start.sh"

# Set the project ID

# Set the zone

# Set the name of the virtual machine
VM_NAME="${PROJECT_NAME}-${BUILD_NO}"

# Set the name of the machine image
IMAGE_NAME="base-image-5"
# Set the startup script file name

# Create the virtual machine
gcloud beta compute instances create $VM_NAME \
--zone=asia-south1-a \
--source-machine-image="base-image-4" \
--service-account="813884923592-compute@developer.gserviceaccount.com"




# Add the startup script
gcloud compute instances add-metadata $VM_NAME \
--zone=asia-south1-a \
--metadata-from-file startup-script="/data/dist/scripts/vm-start.sh"
