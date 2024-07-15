mainterraform {
  required_providers {
    rancher2 = {
      source  = "rancher/rancher2"
      version = "4.2.0"
    }
    latitudesh = {
      source  = "latitudesh/latitudesh"
      version = "1.1.1"
    }
  }
}

provider "rancher2" {
  # Configuration options
  api_url    = var.rancher_api_url
  access_key = var.rancher_access_key
  secret_key = var.rancher_secret_key
  insecure   = true
}

# Configure the provider
provider "latitudesh" {
  auth_token = var.LATITUDESH_AUTH_TOKEN
}