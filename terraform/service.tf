resource "docker_registry_image" "yasitha_registry_image" {
  name          = docker_image.yasitha-demo-docker-image.name
  keep_remotely = true
}

resource "docker_image" "yasitha-demo-docker-image" {
  name = "yasitha-demo-service"
  build {
    context = "../src/"
    tag     = ["yasitha-tf:latest"]
  }
}
