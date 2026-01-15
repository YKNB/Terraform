output "adminer_url" { value = "http://localhost:${var.adminer_port}" }
output "web_url" { value = "http://localhost:${var.web_port}" }

output "postgres" {
  value     = "postgresql://${var.postgres_user}:***@localhost:${var.postgres_port}/${var.postgres_db}"
  sensitive = true
}
