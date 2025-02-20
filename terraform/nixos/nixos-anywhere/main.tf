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

resource "latitudesh_ssh_key" "ubuntu" {
  project    = latitudesh_project.project.id
  name       = "ubuntu"
  public_key = var.SSH_PUBLIC_KEY
}

resource "latitudesh_user_data" "init" {
  project     = latitudesh_project.project.id
  description = "init"
  content = base64encode(templatefile("${path.module}/cloud-config.yaml.tftpl", {
    ssh_key = var.SSH_PUBLIC_KEY
  }))
}

data "local_file" "nixify-sh" {
  filename = "${path.module}/nixify.sh"
}


data "local_file" "nixosify-sh" {
  filename = "${path.module}/nixosify.sh"
}

data "local_file" "disko-install" {
  filename = "${path.module}/disko-install"
}





resource "latitudesh_server" "ubuntu" {
  raid             = "raid-1"
  hostname         = "c2-small-x86-SAO2-nixos"
  plan             = "c2-small-x86"
  operating_system = "ubuntu_24_04_x64_lts"
  project          = latitudesh_project.project.id
  site             = "SAO2"
  ssh_keys         = [latitudesh_ssh_key.ubuntu.id]
  billing          = "hourly"
  locked           = false
  user_data        = latitudesh_user_data.init.id
}

resource "ssh_resource" "nixify" {
  when  = "create"
  host  = latitudesh_server.ubuntu.primary_ipv4
  user  = "ubuntu"
  agent = true

  file {
    content     = data.local_file.nixify-sh.content
    destination = "/home/ubuntu/nixify.sh"
    permissions = "0700"
  }

  file {
    content     = data.local_file.disko-install.content
    destination = "/home/ubuntu/disko-install"
    permissions = "0700"
  }

  commands = [
    "/home/ubuntu/nixify.sh"
  ]


  provisioner "local-exec" {
    when    = create
    command = "./copy-config.sh ubuntu@${latitudesh_server.ubuntu.primary_ipv4}"
  }
}

# resource "ssh_resource" "nixosify" {
#   depends_on = [ ssh_resource.nixify ]
#   when  = "create"
#   host  = latitudesh_server.ubuntu.primary_ipv4
#   user  = "ubuntu"
#   agent = true

#   file {
#     content     = data.local_file.nixosify-sh.content
#     destination = "/home/ubuntu/nixosify.sh"
#     permissions = "0700"
#   }
#   commands = [
#     "/home/ubuntu/nixosify.sh"
#   ]
# }

output "ssh_connection" {
  value = "ssh ubuntu@${latitudesh_server.ubuntu.primary_ipv4}"
}
