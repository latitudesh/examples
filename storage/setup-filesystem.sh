#!/bin/bash

# Check if all arguments are provided
if [ $# -ne 4 ]; then
  echo "Usage: $0 <SECRET_KEY> <USERNAME> <STORAGE_FOLDER> <VOLUME_PATH>"
  exit 1
fi

# Configuration variables
SECRET_KEY=$1
CLIENT_NAME=$2
STORAGE_FOLDER=$3
VOLUME_PATH=$4
FILESYSTEM_NAME="fs-shared"
MONITOR_URL="storage-mon.latitude.co" # Monitors URL

# Function to check command success
check_command_success() {
  if [ $? -ne 0 ]; then
    echo "Command '$1' failed. Exiting."
    exit 1
  fi
}

# Install Ceph client
sudo apt -y install ceph-common > /dev/null 2>&1
check_command_success "sudo apt -y install ceph-common"

# Mount filesystem in a specific directory
echo "Mounting filesystem in $STORAGE_FOLDER..."
sudo mkdir -p "$STORAGE_FOLDER"
sudo mount -t ceph "$MONITOR_URL":"$VOLUME_PATH" "$STORAGE_FOLDER" -o name="$CLIENT_NAME",secret="$SECRET_KEY",fs="$FILESYSTEM_NAME" > /dev/null 2>&1
check_command_success "sudo mount -t ceph"

echo "Storage applied successfully."
