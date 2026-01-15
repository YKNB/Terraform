module "network" {
  source = "./modules/network"
  name   = "tf-lab-net"
}

module "postgres" {
  source            = "./modules/postgres"
  network_name      = module.network.name
  container_name    = "tf-postgres"
  postgres_user     = var.postgres_user
  postgres_password = var.postgres_password
  postgres_db       = var.postgres_db
  external_port     = var.postgres_port
}

module "adminer" {
  source         = "./modules/adminer"
  network_name   = module.network.name
  container_name = "tf-adminer"
  external_port  = var.adminer_port
}

module "web" {
  source         = "./modules/web"
  network_name   = module.network.name
  container_name = "tf-web"
  external_port  = var.web_port
}
