variable "region" {
  type        = string
  description = "The region to deploy the Cloud Run service to"
}

variable "project_id" {
  type    = string
  default = "yasitha-docker-demo"
}

variable "zone" {
  type = string
}

variable "docker_image_name" {
  type = string
}

variable "registry_name" {
  type = string
}
