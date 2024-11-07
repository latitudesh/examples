
variable "JOIN_URL" {
  description = "Tenant Control Plane URL"
  type        = string
  default     = ""
}

variable "JOIN_TOKEN" {
  description = "Join token"
  type        = string
  sensitive   = true
}

variable "JOIN_TOKEN_CACERT_HASH" {
  description = "Join CA certificate hash"
  type        = string
  sensitive   = true
}

variable "LATITUDESH_AUTH_TOKEN" {
  description = "Latitude.sh API token"
  type        = string
  sensitive   = true
}

// Project
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

variable "server_count" {
  description = "The number of server instances to create."
  default     = 3
}