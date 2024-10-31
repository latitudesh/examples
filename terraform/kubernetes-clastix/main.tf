terraform {
  required_providers {
    latitudesh = {
      source  = "latitudesh/latitudesh"
      version = ">= 1.1.2"
    }
  }
}

# Configure the provider
provider "latitudesh" {
  auth_token = var.LATITUDESH_AUTH_TOKEN
}