variable "LATITUDESH_AUTH_TOKEN" {
  description = "Latitude.sh API token"
  default     = ""
}

variable "project_id" {
  description = "ID of the Project to deploy to"
  default     = ""
}

// Plan
variable "plan" {
  description = "Plan to use for deployment. Plan is the instance type slug. You can find this in the /plans endpoint of the API."
}

// Nomad setup
variable "nomad_server_count" {
  description = "The number of Nomad/Consul server instances to create."
  default     = 1
}

variable "nomad_client_count" {
  description = "The number of Nomad/Consul client instances to create."
  default     = 1
}

variable "nomad_region" {
  default = ""
}

variable "nomad_vlan_id" {
  description = "Value of the VLAN ID (VID) to use for the Nomad/Consul instances"
  default     = ""
}

// SSH Keys
variable "service_account_ssh_key_id" {
  default = ""
}

variable "private_key_path" {
  default = ""
}
