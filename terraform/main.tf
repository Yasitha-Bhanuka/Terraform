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

provider "google" {
  project = "yasitha-docker-demo"
  region  = "asia-southeast1"
}

data "google_client_config" "default" {
}

provider "docker" {
  registry_auth {
    address  = "${var.region}-docker.pkg.dev"
    username = "oauth2accesstoken"
    password = data.google_client_config.default.access_token
  }
}

resource "google_artifact_registry_repository" "yasitha_docker_registry_repo" {
  location = var.region

  repository_id = "yasitha-docker-registry-repo"
  format        = "DOCKER"
}

module "api1" {
  source        = "./modules/api"
  name          = "yasitha-tf-super"
  region        = var.region
  port          = var.port
  registry_name = google_artifact_registry_repository.yasitha_docker_registry_repo.repository_id
  depends_on = [
    google_artifact_registry_repository.yasitha_docker_registry_repo
  ]
}
