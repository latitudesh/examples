#!/usr/bin/env bash

# ---
# Arguments
# ---

instanceNumber=$1
numberOfInstances=$2
regionName=$3
vlanID=$4

# Nomad private Client IP
nomad_client_ip="10.8.0.$instanceNumber"

# ---
# Consul configuration
# ---

cat > /etc/consul.d/consul.hcl <<EOF
datacenter = "dc-$regionName-1"
data_dir = "/opt/consul"

node_name = "consul-client-$instanceNumber"

bind_addr = "0.0.0.0"
client_addr = "0.0.0.0"
advertise_addr = "10.8.0.$instanceNumber"

retry_join = [
EOF

for SERVER_NUMBER in $(seq 1 $numberOfInstances); do
    echo "    \"10.8.0.$SERVER_NUMBER\"," >> /etc/consul.d/consul.hcl
done

cat >> /etc/consul.d/consul.hcl <<EOF
]

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

name = "nomad-client-$instanceNumber"

client {
    enabled = true
    options {
        "driver.raw_exec.enable" = "1"
        "docker.privileged.enabled" = "true"
    }
}

consul {
    address = "127.0.0.1:8500"
}

ui {
    enabled = false
}
EOF

# ---
# Update Netplan with VLAN configuration
# ---
vlan_link=$(sudo netplan get network.ethernets | grep -v '^[[:blank:]]' | tail -n 1 | sed 's/.$//')

echo "    vlans:" >> /etc/netplan/50-cloud-init.yaml
echo "        vlan.$vlanID:" >> /etc/netplan/50-cloud-init.yaml
echo "            id: $vlanID" >> /etc/netplan/50-cloud-init.yaml
echo "            link: $vlan_link" >> /etc/netplan/50-cloud-init.yaml
echo "            addresses: [$nomad_client_ip/24]" >> /etc/netplan/50-cloud-init.yaml

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
