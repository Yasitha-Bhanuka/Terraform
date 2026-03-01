resource "google_artifact_registry_repository" "yasitha_docker_registry_repository" {
  location = "asia-southeast1"

  repository_id = "yasitha-docker-registry-repository"
  format        = "DOCKER"
}


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
