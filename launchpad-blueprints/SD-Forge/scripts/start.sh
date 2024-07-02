#!/bin/bash

SSH_USER=${SSH_USER:-root}

# Check if SSH_USER exists, if not create it
if ! id "$SSH_USER" &>/dev/null; then
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

mkdir -p /workspace/stable-diffusion-webui-forge
mv /temp/stable-diffusion-webui-forge/* /workspace/stable-diffusion-webui-forge
mv /temp/stable-diffusion-webui-forge/.* /workspace/stable-diffusion-webui-forge

cd /workspace/stable-diffusion-webui-forge/venv/bin
sed -i "s|/temp/stable-diffusion-webui-forge|/workspace/stable-diffusion-webui-forge|g" *

cd /workspace/stable-diffusion-webui-forge

source venv/bin/activate

exec /usr/sbin/sshd -D & 

nohup jupyter-lab --allow-root --ip  0.0.0.0 --NotebookApp.token='' --notebook-dir ./ --NotebookApp.allow_origin=* --NotebookApp.allow_remote_access=1 &

python launch.py --listen --opt-sdp-attention