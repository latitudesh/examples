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

resource "latitudesh_server" "nixos" {
  hostname         = "c2-small-x86-SAO2-nixos"
  plan             = "c2-small-x86"
  operating_system = "ubuntu_24_04_x64_lts"
  project          = latitudesh_project.project.id
  site             = "SAO2"
  ssh_keys         = [latitudesh_ssh_key.root.id]
  billing          = "hourly"
  locked           = false
  user_data = latitudesh_user_data.init.id
}

output "ssh_connection" {
  value = "ssh ubuntu@${latitudesh_server.nixos.primary_ipv4}"
}

# enp1s0f0
# services.openssh.settings.ClientAliveInterval = 180;