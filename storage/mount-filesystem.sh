#!/bin/bash
set -e  # Exit immediately if a command exits with a non-zero status

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration variables
SECRET_KEY=$1
CLIENT_NAME=$2
VOLUME_ID=$3
STORAGE_FOLDER=${4:-$(read -p "Enter the storage folder path: " folder && echo $folder)}

FILESYSTEM_NAME="fs-shared"
MONITOR_URL="storage-mon.latitude.co"
COMMON_VOLUME_PATH="/volumes/csi/csi-vol-"
VOLUME_PATH="${COMMON_VOLUME_PATH}${VOLUME_ID}"

# Function to check if filesystem is mounted
check_mount() {
    if mount | grep -q "$STORAGE_FOLDER"; then
        echo -e "${GREEN}Filesystem is successfully mounted at $STORAGE_FOLDER${NC}"
        return 0
    else
        echo -e "${RED}Error: Filesystem is not mounted at $STORAGE_FOLDER${NC}"
        return 1
    fi
}

# Install Ceph client
echo -e "${BLUE}Installing storage client...${NC}"
sudo apt -y install ceph-common > /dev/null 2>&1

# Validate storage folder input
if [ -z "$STORAGE_FOLDER" ]; then
    echo -e "${RED}Error: Storage folder path cannot be empty.${NC}"
    exit 1
fi

# Create Ceph configuration file
echo -e "${BLUE}Creating configuration file...${NC}"
sudo tee /etc/ceph/ceph.conf > /dev/null << EOF
[global]
mon host = ${MONITOR_URL}
EOF

# Create Ceph keyring file
echo -e "${BLUE}Adding credentials...${NC}"
sudo tee /etc/ceph/ceph.client.${CLIENT_NAME}.keyring > /dev/null << EOF
[client.${CLIENT_NAME}]
    key = ${SECRET_KEY}
EOF

# Set proper permissions for the keyring file
sudo chmod 600 /etc/ceph/ceph.client.${CLIENT_NAME}.keyring

# Mount filesystem
echo -e "${BLUE}Mounting filesystem in $STORAGE_FOLDER...${NC}"
sudo mkdir -p "$STORAGE_FOLDER"
sudo mount -t ceph "$MONITOR_URL:$VOLUME_PATH" "$STORAGE_FOLDER" -o name="$CLIENT_NAME",secret="$SECRET_KEY",fs="$FILESYSTEM_NAME",_netdev,noatime

# Set permissions to allow group write access
echo -e "${BLUE}Setting permissions on $STORAGE_FOLDER...${NC}"
sudo chmod 775 "$STORAGE_FOLDER"

# Create a shared group for users who need write access
SHARED_GROUP="storage-users"
sudo groupadd -f "$SHARED_GROUP"

# Change group ownership of the mount point
sudo chgrp "$SHARED_GROUP" "$STORAGE_FOLDER"

# Set the SGID bit to ensure new files/folders inherit the group
sudo chmod g+s "$STORAGE_FOLDER"

# Verify mount
check_mount

echo -e "${GREEN}Script completed. Mount point $STORAGE_FOLDER is set up with permissions for group writing.${NC}"
echo -e "${YELLOW}Users who need write access should be added to the '$SHARED_GROUP' group.${NC}"
echo -e "${YELLOW}To add a user to this group, run: ${NC}sudo usermod -aG $SHARED_GROUP username"
echo -e "${YELLOW}Note: Users will need to log out and log back in for the new group membership to take effect.${NC}"