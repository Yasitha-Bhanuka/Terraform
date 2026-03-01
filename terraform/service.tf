resource "docker_image" "yasitha-demo-docker-image" {
  name = local.docker_image_url
  build {
    context = "../src/"
    tag     = ["yasitha-tf:latest"]
  }
}

resource "google_artifact_registry_repository" "yasitha_docker_registry_repo" {
  location = var.region

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

resource "google_cloud_run_service" "yasitha_service" {
  name     = "yasitha-service"
  location = var.region

  template {
    spec {
      containers {
        image = docker_registry_image.yasitha_registry_image.name
      }
    }
  }

  depends_on = [
    docker_registry_image.yasitha_registry_image
  ]
}
