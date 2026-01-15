variable "network_name" { type = string }
variable "container_name" { type = string }

variable "postgres_user" { type = string }
variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_db" { type = string }

variable "external_port" { type = number }
