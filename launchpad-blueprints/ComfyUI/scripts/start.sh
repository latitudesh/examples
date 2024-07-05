#!/bin/bash

# Configure SSH
sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

# Default SSH user to root if not provided
SSH_USER=${SSH_USER:-root}

# Check if SSH_USER exists, if not create it
if ! id "$SSH_USER" &>/dev/null; then
    useradd -m $SSH_USER
fi

# If a PUBLIC_KEY environment variable is provided, add the key to the SSH_USER
if [ -n "$PUBLIC_KEY" ]; then
    HOME_DIR=$(getent passwd "$SSH_USER" | cut -d: -f6)
    mkdir -p $HOME_DIR/.ssh
    echo $PUBLIC_KEY > $HOME_DIR/.ssh/authorized_keys
    chown -R $SSH_USER:$SSH_USER $HOME_DIR/.ssh
    chmod 700 $HOME_DIR/.ssh
    chmod 600 $HOME_DIR/.ssh/authorized_keys
fi

# Start the SSH service
service ssh start

mkdir -p /workspace/ComfyUI
mv /temp/ComfyUI/* /workspace/ComfyUI
mv /temp/ComfyUI/.* /workspace/ComfyUI

cd /workspace/ComfyUI/venv/bin
sed -i "s|/temp/ComfyUI|/workspace/ComfyUI|g" *

cd /workspace/ComfyUI

exec /usr/sbin/sshd -D & 

. venv/bin/activate && nohup jupyter-lab --allow-root --ip  0.0.0.0 --NotebookApp.token='' --notebook-dir /workspace/ComfyUI --NotebookApp.allow_origin=* --NotebookApp.allow_remote_access=1 &

. venv/bin/activate && python /workspace/ComfyUI/main.py --listen
