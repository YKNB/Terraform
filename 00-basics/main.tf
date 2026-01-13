resource "docker_network" "lab" {
  name = "tf-lab-net"
}

resource "docker_image" "postgres" {
  name = "postgres:16-alpine"
}

resource "docker_container" "postgres" {
  name  = "tf-postgres"
  image = docker_image.postgres.image_id

  env = [
    "POSTGRES_PASSWORD=${var.postgres_password}",
    "POSTGRES_USER=${var.postgres_user}",
    "POSTGRES_DB=${var.postgres_db}",
  ]

  networks_advanced { name = docker_network.lab.name }

  ports {
    internal = 5432
    external = var.postgres_port
  }
}

resource "docker_image" "adminer" {
  name = "adminer:latest"
}

resource "docker_container" "adminer" {
  name  = "tf-adminer"
  image = docker_image.adminer.image_id

  networks_advanced { name = docker_network.lab.name }

  ports {
    internal = 8080
    external = var.adminer_port
  }

  depends_on = [docker_container.postgres]
}

resource "docker_image" "nginx" {
  name = "nginx:alpine"
}

resource "docker_container" "web" {
  name  = "tf-web"
  image = docker_image.nginx.image_id

  networks_advanced { name = docker_network.lab.name }

  ports {
    internal = 80
    external = var.web_port
  }
}
