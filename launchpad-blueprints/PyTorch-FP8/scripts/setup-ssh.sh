#!/bin/bash

# Define SSH_USER to 'root' if it is not set
SSH_USER=${SSH_USER:-root}

# Check if SSH_USER exists. If not, create it (root is ignored, as it should already exist)
if ! id "$SSH_USER" &>/dev/null && [ "$SSH_USER" != "root" ]; then
    useradd -m $SSH_USER
fi

# If a PUBLIC_KEY environment variable is provided, add the key to the SSH_USER
if [ -n "$PUBLIC_KEY" ]; then
    # Determine correct home directory
    HOME_DIR=$(getent passwd "$SSH_USER" | cut -d: -f6)
    mkdir -p $HOME_DIR/.ssh
    echo $PUBLIC_KEY > $HOME_DIR/.ssh/authorized_keys
    chown -R $SSH_USER:$SSH_USER $HOME_DIR/.ssh
    chmod 700 $HOME_DIR/.ssh
    chmod 600 $HOME_DIR/.ssh/authorized_keys
fi

# Start the SSH service
exec /usr/sbin/sshd -D
