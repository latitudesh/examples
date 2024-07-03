#!/bin/sh

SSH_USER=${SSH_USER:-root}
 
if ! id "$SSH_USER" &>/dev/null && [ "$SSH_USER" != "root" ]; then
    useradd -m $SSH_USER
fi

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


mkdir -p /workspace/a1111
mv /temp/a1111/* /workspace/a1111
mv /temp/a1111/.* /workspace/a1111

cd /workspace/a1111/venv/bin
sed -i "s|/temp/a1111|/workspace/a1111|g" *

cd /workspace/a1111

exec /usr/sbin/sshd -D & 

. venv/bin/activate && nohup jupyter-lab --allow-root --ip  0.0.0.0 --NotebookApp.token='' --notebook-dir /workspace/a1111 --NotebookApp.allow_origin=* --NotebookApp.allow_remote_access=1 &

. venv/bin/activate && python launch.py --listen --opt-sdp-attention