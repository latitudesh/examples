This repository indicates the Harvester installation steps in an automated way, replacing all place holders correctly this script will deliver the Harvester ready for operation.

# Intro

Harvester is a modern hyperconverged infrastructure (HCI) solution built for bare metal servers using enterprise-grade open-source technologies including Linux, KVM, Kubernetes, KubeVirt, and Longhorn. Designed for users looking for a flexible and affordable solution to run cloud-native and virtual machine (VM) workloads in your datacenter and at the edge, Harvester provides a single pane of glass for virtualization and cloud-native workload management.

Harvester operates on Kubevirt, Longhorn, and RKE2. RKE2 provides an orchestration infrastructure layer, while Kubevirt offers pods with virtualization capabilities. This allows for advanced features needed by virtual machines, such as running their own kernel. Longhorn acts as a block storage manager, delivering hard disks for virtual machines.

# Installation

> All files used to deployment must be public available at the moment of deployment.

## iPXE Script

The iPXE script [boot.ipxe](https://github.com/latitudesh/examples/blob/main/custom-image-harvester/boot.ipxe) used to harvester automatic install is shown below:

```bash
#!ipxe

ifopen net{{ INTERFACE_ID }}
set net{{ INTERFACE_ID }}/ip {{ PUBLIC_IP }}
set net{{ INTERFACE_ID }}/netmask {{ NETMASK }}
set net{{ INTERFACE_ID }}/gateway {{ PUBLIC_GW }}
set net{{ INTERFACE_ID }}/dns 8.8.8.8


kernel https://releases.rancher.com/harvester/master/harvester-master-vmlinuz-amd64 ip={{ PUBLIC_IP }}::{{ PUBLIC_GW }}:{{ NETMASK }}::enp1s0f{{ INTERFACE_ID }}:off:8.8.8.8 rd.cos.disable rd.noverifyssl net.ifnames=1 root=live:https://releases.rancher.com/harvester/master/harvester-master-rootfs-amd64.squashfs console=ttyS1,115200n8 harvester.install.automatic=true harvester.install.skipchecks=true harvester.install.config_url={{HARVESTER-CONFIG-FILE}}
initrd https://releases.rancher.com/harvester/master/harvester-master-initrd-amd64
boot

```

The place holder {{HARVESTER-CONFIG-FILE}} must be replaced by url of the config HARVESTER-CONFIG-FILE.yaml

Special attention to the following parameters:

> harvester.install.config_url={{HARVESTER-CONFIG-FILE}}

This parameter points to the configuration file that determines how the installation will be performed. This will be detailed in the next session.

> console=ttyS1,115200n8

This parameter should be used to make harvester installer use serial console, this option allows [out-of-band](https://www.latitude.sh/docs/servers/out-of-band) to be used to monitor the installation.

## Harvester Config Files

### Create Cluster

Harvester deployment requires a special configuration for the first node.

A token must be defined, and this will be used later to join new nodes to the cluster.

> token: {{CLUSTER-TOKEN}} 

Another parameter used to join new node to cluster is VIP. The IP address used as VIP must be dedicated, otherwise the installation will fail, so it is necessary request an [additional IP](https://www.latitude.sh/docs/networking/ips). 

> vip: {{VIRTUAL-IP-FOR-CLUSTER-MANAGEMENT}}

```bash
scheme_version: 1
token: {{CLUSTER-TOKEN}}            
os:
  hostname: {{HOSTNAME}}      # Set a hostname. This can be omitted if DHCP server offers hostnames.
  ssh_authorized_keys:
  - {{SSH_PUBLIC_KEY}}
  password: {{ENCRYPTED_PASSWORD}}
  ntp_servers:
  - 0.suse.pool.ntp.org
  - 1.suse.pool.ntp.org
  dns_nameservers:
    - 8.8.8.8
    - 1.1.1.1
install:
  mode: create
  management_interface:
    interfaces:
      - name: {{INTERFACE_NAME}}
    default_route: true
    method: static
    bond_options:
      miimon: 100
    ip: {{PUBLIC_IP}}
    subnet_mask: {{PUBLIC_SUBNET}}
    gateway: {{PUBLIC_GW}}
  device: {{BLOCK-STORAGE-DEVICE}}
  iso_url: https://releases.rancher.com/harvester/master/harvester-master-amd64.iso
  tty: ttyS1,115200n8   # For machines without a VGA console

  vip: {{VIRTUAL-IP-FOR-CLUSTER-MANAGEMENT}}
  vip_mode: static                   # Or static
  vip_hw_addr:   # Leave empty when vip_mode is static

```

> harvester.install.config_url at boot.ipxe must point to HARVESTER-CONFIG-FILE url.

### Add Node to Cluster

The HARVESTER-ADD-NODE-TO-CLUSTER.yaml configuration file pertains to any other node added after the first one. Since the cluster is already up, the new node will join the cluster.

In this case no additional IP is required, and a new parameter is introduced:

> server_url: https://{{VIRTUAL-IP-FOR-CLUSTER-MANAGEMENT}}:443


```bash
scheme_version: 1
server_url: https://{{VIRTUAL-IP-FOR-CLUSTER-MANAGEMENT}}:443
token: {{CLUSTER-TOKEN}}          
os:
  hostname: {{HOSTNAME}}       # Set a hostname. This can be omitted if DHCP server offers hostnames.
  ssh_authorized_keys:
  - {{SSH_PUBLIC_KEY}}
  password: {{ENCRYPTED_PASSWORD}}
  - 0.suse.pool.ntp.org
  - 1.suse.pool.ntp.org
  dns_nameservers:
    - 8.8.8.8
    - 1.1.1.1
install:
  mode: join
  management_interface:
    interfaces:
      - name: {{INTERFACE_NAME}}
    default_route: true
    method: static
    bond_options:
      miimon: 100
    ip: {{PUBLIC_IP}}
    subnet_mask:  {{PUBLIC_SUBNET}}
    gateway: {{PUBLIC_GW}}
  device: {{BLOCK-STORAGE-DEVICE}}       # The target disk to install
  iso_url: https://releases.rancher.com/harvester/master/harvester-master-amd64.iso
  tty: ttyS1,115200n8   # For machines without a VGA console

```

> harvester.install.config_url at boot.ipxe must point to HARVESTER-ADD-NODE-TO-CLUSTER url.

# Troubleshooting

Special attention must be applied to disk device: {{BLOCK-STORAGE-DEVICE}}  and network interface name: {{INTERFACE_NAME}}

The names of block storage device and network interface may make the installation failure for different reasons: 

- Since it is a network installation, the harvester installer needs internet access to retrieve installation files. If the network interface name is wrong, then there will be no internet access and the installation will fail.
- If name of the block storage device is wrong the harvester installer will fail.

In both cases the installer will enter in emergency shell, if this occurs you can look into network interfaces names and block storage devices names and adjust the config files.

# Reference

[Harvester Site](https://harvesterhci.io/)

[Harvester iPXE repo](https://github.com/harvester/ipxe-examples)

[Custom Images](https://www.latitude.sh/docs/servers/custom-images)

[iPXE](https://ipxe.org/)