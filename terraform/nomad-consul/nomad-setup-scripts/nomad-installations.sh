#!/usr/bin/env bash

# ---
# Update the system
# ---

# Ubuntu 22.04 prompts the user by default when daemons need to be
# restarted following an update/upgrade/installation. Use this command
# to have Ubuntu only list the services instead.
#
# Comment out this line if you are not standing up Ubuntu 22.04.
echo "\$nrconf{restart} = 'l'" >> /etc/needrestart/conf.d/no-prompt.conf

# Update the system
apt-get update -qq

# ---
# Add HashiCorp repository
# ---

# Install the prerequisites
apt install -yq wget gpg coreutils

# Add the HashiCorp repository
wget -O- https://apt.releases.hashicorp.com/gpg | gpg --dearmor | tee /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | tee /etc/apt/sources.list.d/hashicorp.list

# ---
# Install Nomad
# ---

apt update
apt install -yq nomad

# Install the CNI plugins for Nomad
curl -L -o cni-plugins.tgz "https://github.com/containernetworking/plugins/releases/download/v1.0.0/cni-plugins-linux-$( [ $(uname -m) = aarch64 ] && echo arm64 || echo amd64)"-v1.0.0.tgz
mkdir -p /opt/cni/bin
tar -C /opt/cni/bin -xzf cni-plugins.tgz

# Add iptables rules for the bridge network
tee /etc/sysctl.d/bridge.conf > /dev/null <<EOF
net.bridge.bridge-nf-call-arptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
EOF

modprobe br_netfilter
sysctl -p /etc/sysctl.d/bridge.conf

# ---
# Install Consul
# ---

apt install -yq consul

# ---
# Install Docker
# ---

apt install -yq ca-certificates curl gnupg lsb-release
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install -yq docker-ce docker-ce-cli containerd.io docker-compose-plugin
