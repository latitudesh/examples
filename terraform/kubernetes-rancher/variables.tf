variable "LATITUDESH_AUTH_TOKEN" {
  description = "Latitude.sh API token"
  type        = string
  sensitive   = true
}

variable "project_id" {
  description = "ID of the Project to deploy to"
  default     = ""
}

// Plan
variable "plan" {
  description = "Plan to use for deployment. Plan is the instance type slug. You can find this in the /plans endpoint of the API."
  default     = ""
}

// Region
variable "region" {
  description = "Latitude.sh server region slug"
  default     = ""
}

// SSH Keys
variable "ssh_key_id" {
  default = "" # The key can't contain a passphrase
}

variable "private_key_path" {
  description = "Path of private ssh key"
  default = "~/.ssh/id_rsa"
}

variable "rancher_api_url" {
  description = "rancher api url"
  default = ""
}

variable "RANCHER_ACCESS_KEY" {
  description = "rancher api access key"
  type        = string
  sensitive   = true
}

variable "RANCHER_SECRET_KEY" {
  description = "rancher api secret key"
  type        = string
  sensitive   = true
}

variable "server_count" {
  description = "The number of server instances to create."
  default     = 2
}