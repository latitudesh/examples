#!/usr/bin/env bash

# ---
# Arguments
# ---

instanceNumber=$1
numberOfInstances=$2
regionName=$3
vlanID=$4

# Nomad Server IP for VLAN
nomad_server_ip="10.8.0.$instanceNumber"

# ---
# Consul configuration
# ---

cat > /etc/consul.d/consul.hcl <<EOF
datacenter = "dc-$regionName-1"
data_dir = "/opt/consul"

node_name = "consul-server-$instanceNumber"

bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
advertise_addr = "$nomad_server_ip"

bootstrap_expect = $numberOfInstances

server = true
ui = true

retry_join = [
EOF

for SERVER_NUMBER in $(seq 1 $numberOfInstances); do
    echo "    \"10.8.0.$SERVER_NUMBER\"," >> /etc/consul.d/consul.hcl
done

cat >> /etc/consul.d/consul.hcl <<EOF
]

service {
    name = "consul"
}

connect {
    enabled = true
}

ports {
    grpc = 8502
}
EOF

# ---
# Nomad configuration
# ---

cat > /etc/nomad.d/nomad.hcl <<EOF
datacenter = "dc-$regionName-1"
data_dir = "/opt/nomad/data"

bind_addr = "0.0.0.0"

name = "nomad-server-$instanceNumber"

server {
    enabled = true
    bootstrap_expect = $numberOfInstances
}

consul {
    address = "127.0.0.1:8500"
}
EOF

# ---
# Update Netplan with VLAN configuration
# ---

echo "    vlans:" >> /etc/netplan/50-cloud-init.yaml
echo "        vlan.$vlanID:" >> /etc/netplan/50-cloud-init.yaml
echo "            id: $vlanID" >> /etc/netplan/50-cloud-init.yaml
echo "            link: eno2" >> /etc/netplan/50-cloud-init.yaml
echo "            addresses: [$nomad_server_ip/24]" >> /etc/netplan/50-cloud-init.yaml

# Apply Netplan configuration
sudo netplan apply

# ---
# Running Consul
# ---
systemctl enable consul
systemctl start consul

# ---
# Running Nomad
# ---
systemctl enable nomad
systemctl start nomad
