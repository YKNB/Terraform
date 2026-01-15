resource "docker_image" "adminer" {
  name = "adminer:latest"
}

resource "docker_container" "adminer" {
  name  = var.container_name
  image = docker_image.adminer.image_id

  networks_advanced {
    name = var.network_name
  }

  ports {
    internal = 8080
    external = var.external_port
  }

}
