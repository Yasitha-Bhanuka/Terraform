resource "docker_image" "yasitha-demo-docker-image" {
  name = "asia-southeast1-docker.pkg.dev/yasitha-docker-demo/${google_artifact_registry_repository.yasitha_docker_registry_repo.repository_id}/hexcoder-tf"
  build {
    context = "../src/"
    tag     = ["yasitha-tf:latest"]
  }
}

resource "google_artifact_registry_repository" "yasitha_docker_registry_repo" {
  location = "asia-southeast1"

  repository_id = "yasitha-docker-registry-repo"
  format        = "DOCKER"
}

resource "docker_registry_image" "yasitha_registry_image" {
  name          = docker_image.yasitha-demo-docker-image.name
  keep_remotely = true
  depends_on = [
    docker_image.yasitha-demo-docker-image, google_artifact_registry_repository.yasitha_docker_registry_repo
  ]
}


