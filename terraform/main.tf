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
  zone    = "asia-southeast1-a"
}

data "google_client_config" "current" {
}

provider "docker" {
  registry_auth {
    address  = "asia-southeast1-docker.pkg.dev"
    username = "oauth2accesstoken"
    password = data.google_client_config.default.access_token
  }
}
