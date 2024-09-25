#!/bin/bash

# Function to display usage
usage() {
    echo "Usage: $0 -firewall <firewall_id>"
    exit 1
}

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    key="$1"
    case $key in
        -firewall)
        FIREWALL_ID="$2"
        shift # past argument
        shift # past value
        ;;
        *)
        usage
        ;;
    esac
done

# Check if firewall ID is provided
if [ -z "$FIREWALL_ID" ]; then
    echo "Error: Firewall ID is required."
    usage
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Function to install a package
install_package() {
    if command -v apt-get &> /dev/null; then
        apt-get update && apt-get install -y "$1"
    elif command -v yum &> /dev/null; then
        yum install -y "$1"
    else
        echo "Unable to install $1. Please install it manually."
        return 1
    fi
}

# Install curl if not present
if ! command -v curl &> /dev/null; then
    install_package curl || exit 1
fi

# Install and enable UFW if not present
if ! command -v ufw &> /dev/null; then
    echo "Installing UFW..."
    install_package ufw || exit 1
fi

# Enable UFW if it's not active
if ! ufw status | grep -q "Status: active"; then
    echo "Enabling UFW..."
    ufw --force enable
    ufw default deny incoming
    ufw default allow outgoing
    ufw allow ssh
    echo "UFW enabled and configured with default rules"
else
    echo "UFW is already active"
fi

# Download and install rules.sh
curl -s https://gist.githubusercontent.com/esoubihe/908833a2d11d246330994854aa9e22ce/raw/2b3613b98544b8ca9e731420412012fa2779b1f4/rules.sh -o /usr/local/bin/rules.sh
chmod +x /usr/local/bin/rules.sh

# Download and install rule-fetch.service
curl -s https://gist.githubusercontent.com/esoubihe/97563a21628f62bc58fe4bc7c6442402/raw/51738791f88c0638e41781ae1cf1399369edebe3/rule-fetch.service -o /etc/systemd/system/rule-fetch.service

# Add security group ID to the environment file
echo "FIREWALL_ID=$FIREWALL_ID" > /etc/latitude-agent-env

# Reload systemd, enable and start the service
systemctl daemon-reload
systemctl enable rule-fetch.service
systemctl start rule-fetch.service

echo "Installation completed successfully. Server associated with Firewall $FIREWALL_ID"

# Get hostname and IP address
HOSTNAME=$(hostname)
IP=$(hostname -I | awk '{print $1}')

# Send POST request
echo "Sending server information to Latitude..."
RESPONSE=$(curl -s -w "\n%{http_code}" -X POST https://jqpnqhcawxpkuqyocahc.supabase.co/rest/v1/firewall_servers \
     -H "Content-Type: application/json" \
     -H "apikey: eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImpxcG5xaGNhd3hwa3VxeW9jYWhjIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MjYyNDM4MzcsImV4cCI6MjA0MTgxOTgzN30.Qc_KGvQW60XMqIxA-1_KjoUvbsWFb7v9Vo3SeBiXAN4" \
     -d "{
         \"hostname\": \"$HOSTNAME\",
         \"ip\": \"$IP\",
         \"firewall\": \"$FIREWALL_ID\"
     }")

HTTP_STATUS=$(echo "$RESPONSE" | tail -n1)
RESPONSE_BODY=$(echo "$RESPONSE" | sed '$d')

if [ "$HTTP_STATUS" -eq 201 ]; then
    echo "Server information successfully sent to Latitude."
else
    echo "Error sending server information to Latitude. HTTP Status: $HTTP_STATUS"
    echo "Error details: $RESPONSE_BODY"
fi

echo "
IMPORTANT: Please approve this server in your Latitude dashboard.
Visit: https://latitude.sh/dashboard/team-id/project-id/security/firewall/$FIREWALL_ID

Replace 'team-id' and 'project-id' with your actual team and project IDs.
"