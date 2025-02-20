terraform {
  required_providers {
    latitudesh = {
      source  = "latitudesh/latitudesh"
      version = "1.2.0"
    }
    ssh = {
      source  = "loafoe/ssh"
      version = "2.7.0"
    }
  }
}


variable "LATITUDESH_AUTH_TOKEN" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "LATITUDESH_PROJECT_NAME" {
  type        = string
  sensitive   = false
  nullable    = false
  description = "will create separate project to manage resources"
}

variable "SSH_PUBLIC_KEY" {
  nullable    = false
  type        = string
  sensitive   = true
  description = "publi key to be used by cloud init and by nixos configuration"
}

provider "latitudesh" {
  auth_token = var.LATITUDESH_AUTH_TOKEN
}

resource "latitudesh_project" "project" {
  name              = var.LATITUDESH_PROJECT_NAME
  environment       = "Development"
  provisioning_type = "on_demand"
}

resource "latitudesh_ssh_key" "root" {
  project    = latitudesh_project.project.id
  name       = "admin"
  public_key = var.SSH_PUBLIC_KEY
}

resource "latitudesh_user_data" "init" {
  project     = latitudesh_project.project.id
  description = "init"
  content = base64encode(templatefile("${path.module}/cloud-config.yaml.tftpl", {
    ssh_key = var.SSH_PUBLIC_KEY
  }))
}

resource "latitudesh_server" "ubuntu-clean" {
  raid = "raid-1"
  hostname         = "c2-small-x86-SAO2-nixos"
  plan             = "c2-small-x86"
  operating_system = "ubuntu_24_04_x64_lts"
  project          = latitudesh_project.project.id
  site             = "SAO2"
  ssh_keys         = [latitudesh_ssh_key.root.id]
  billing          = "hourly"
  locked           = false
  user_data        = latitudesh_user_data.init.id 
}

resource "latitudesh_server" "ubuntu" {
  raid = "raid-1"
  hostname         = "c2-small-x86-SAO2-nixos"
  plan             = "c2-small-x86"
  operating_system = "ubuntu_24_04_x64_lts"
  project          = latitudesh_project.project.id
  site             = "SAO2"
  ssh_keys         = [latitudesh_ssh_key.root.id]
  billing          = "hourly"
  locked           = false
  user_data        = latitudesh_user_data.init.id
}

resource "null_resource" "nixos" {
  depends_on = [ latitudesh_server.ubuntu ]
  provisioner "local-exec" {
    command = "nix run github:nix-community/nixos-anywhere -- --flake .#default --generate-hardware-config nixos-facter facter.json ubuntu@${latitudesh_server.ubuntu.primary_ipv4}"
  }
}


resource "null_resource" "nixos2" {
  depends_on = [ latitudesh_server.ubuntu ]
  provisioner "local-exec" {
    command = "nix run github:nix-community/nixos-anywhere -- --flake .#default --generate-hardware-config nixos-facter facter.json ubuntu@103.14.27.107"
  }
}


output "ssh_connection" {
  value = "ssh ubuntu@${latitudesh_server.ubuntu.primary_ipv4}"
}

output "ssh_connection2" {
  value = "ssh ubuntu@${latitudesh_server.ubuntu-clean.primary_ipv4}"
}

# enp1s0f0
# services.openssh.settings.ClientAliveInterval = 180;


# null_resource.nixos (local-exec): + uname -r
# null_resource.nixos (local-exec): + printf %s\n 6.1 6.8.0-53-generic
# null_resource.nixos (local-exec): + kexecSyscallFlags=--kexec-syscall-auto
# null_resource.nixos (local-exec): + sh -c '/root/kexec/kexec/kexec' --load '/root/kexec/kexec/bzImage'   --kexec-syscall-auto      --initrd='/root/kexec/kexec/initrd' --no-checks   --command-line 'init=/nix/store/4g9j050k7pnbb2n43dssv6sndfarl81n-nixos-system-nixos-installer-24.11pre-git/init nouveau.modeset=0 console=tty0 console=ttyS0,115200 root=fstab loglevel=4'
# null_resource.nixos (local-exec): machine will boot into nixos in 6s...
# null_resource.nixos (local-exec): + echo machine will boot into nixos in 6


  # network:
  #   network:
  #     version: 2
  #     ethernets:
  #       enp1s0f0:
  #         dhcp4: no
  #         addresses: [$PUBLIC_IP]
  #         gateway4: $PUBLIC_GATEWAY
  #         nameservers:
  #           addresses: [8.8.8.8, 8.8.4.4]