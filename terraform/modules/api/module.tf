terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.12.0"
    }

    docker = {
      source  = "kreuzwerker/docker"
      version = "3.0.2"
    }
  }
}


resource "docker_image" "yasitha-demo-docker-image" {
  name = local.docker_image_url
  build {
    context = "../src/"
    tag     = ["yasitha-tf:latest"]
  }
}

resource "docker_registry_image" "yasitha_registry_image" {
  name          = docker_image.yasitha-demo-docker-image.name
  keep_remotely = true
  depends_on = [
    docker_image.yasitha-demo-docker-image
  ]
}

resource "google_cloud_run_service" "yasitha_service" {
  name     = var.name
  location = var.region

  template {
    spec {
      containers {
        image = docker_registry_image.yasitha_registry_image.name
        ports {
          container_port = var.port
        }
      }
    }
  }

  depends_on = [
    docker_registry_image.yasitha_registry_image
  ]
}
