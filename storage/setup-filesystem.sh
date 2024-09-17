#!/bin/bash

# Configuration variables
SECRET_KEY=$1
CLIENT_NAME=$2
FILESYSTEM_NAME="fs-shared"
STORAGE_FOLDER=$3
MONITOR_URL="storage-mon.latitude.co"
VOLUME_PATH=$4

# Check if storage path is provided
if [ -z "$STORAGE_FOLDER" ]; then
  echo "Storage path not provided. Please provide the storage path as an argument."
  echo "Script completed with failure."
  exit 1
fi

# Install Ceph client
sudo apt -y install ceph-common > /dev/null 2>&1
check_command_success "sudo apt -y install ceph-common" > /dev/null 2>&1

# Check if storage path is provided
if [ -z "$STORAGE_FOLDER" ]; then
  echo "Storage path not provided. Please provide the storage path as an argument."
  exit 1
fi

# Mount filesystem in a specific directory
echo "Mounting filesystem in $STORAGE_FOLDER..."
sudo mkdir -p $STORAGE_FOLDER
sudo mount -t ceph $MONITOR_URL:$VOLUME_PATH $STORAGE_FOLDER -o name=$CLIENT_NAME,secret=$SECRET_KEY,fs=$FILESYSTEM_NAME > /dev/null 2>&1
check_command_success "sudo mount -t ceph $MONITOR_URL:$VOLUME_PATH $STORAGE_FOLDER -o name=$CLIENT_NAME,secret=$SECRET_KEY,fs=$FILESYSTEM_NAME" > /dev/null 2>&1

echo "Script completed successfully."