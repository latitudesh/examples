# Use the PyTorch base image
FROM nvcr.io/nvidia/pytorch:24.03-py3

RUN apt-get update && apt-get install -y openssh-server sudo

# Create the necessary directory for SSH
RUN mkdir /var/run/sshd

# Expose the SSH port
EXPOSE 22

# Add a setup script for SSH keys
COPY scripts/setup-ssh.sh /usr/local/bin/setup-ssh.sh
RUN chmod +x /usr/local/bin/setup-ssh.sh

# Run the setup script and start the SSH server
CMD ["/usr/local/bin/setup-ssh.sh"]