terraform {
  required_providers {
    latitudesh = {
      source  = "latitudesh/latitudesh"
      version = "1.2.0"
    }
  }
}


variable "LATITUDESH_AUTH_TOKEN" {
  type      = string
  sensitive = true
  nullable  = false
}

variable "LATITUDESH_PROJECT_NAME" {
  type      = string
  sensitive = false
  nullable  = false
  description = "will create separate project to manage resources"
}

variable "SSH_PUBLIC_KEY" {
  nullable = false
  type     = string
  sensitive = true
  description = "publi key to be used by cloud init and by nixos configuration"
}

provider "latitudesh" {
  auth_token = var.LATITUDESH_AUTH_TOKEN
}

resource "latitudesh_project" "project" {
  name        = var.LATITUDESH_PROJECT_NAME
  environment = "Development"
  provisioning_type = "on_demand"
}

resource "latitudesh_ssh_key" "root" {
  project    = latitudesh_project.project.id
  name       = "admin"
  public_key = var.SSH_PUBLIC_KEY
}
