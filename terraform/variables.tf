variable "project_id" {}

variable "region" {
  default = "us-central1"
}

variable "zone" {
  default = "us-central1-a"
}

variable "vm_name" {
  default = "n8n-backoffice"
}

variable "machine_type" {
  default = "e2-small"
}

variable "disk_size_gb" {
  default = 20
}
