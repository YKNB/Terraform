output "adminer_url" {
  value = "http://localhost:${var.adminer_port}"
}

output "web_url" {
  value = "http://localhost:${var.web_port}"
}

output "network" {
  value = module.network.name
}
