locals {
  docker_image_url = "${var.region}-docker.pkg.dev/yasitha-docker-demo/${var.registry_name}/${var.name}-image:${formatdate("YYYYMMDDhhmmssZ", timestamp())}"
}
