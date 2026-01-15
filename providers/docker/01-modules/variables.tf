variable "postgres_user" {
  type    = string
  default = "lab"
}

variable "postgres_db" {
  type    = string
  default = "labdb"
}

variable "postgres_password" {
  type      = string
  sensitive = true
}

variable "postgres_port" {
  type    = number
  default = 55432
}

variable "adminer_port" {
  type    = number
  default = 8081
}

variable "web_port" {
  type    = number
  default = 8080
}
