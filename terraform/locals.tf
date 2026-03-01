locals {
  docker_image_url = "${var.region}-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.yasitha_docker_registry_repo.repository_id}/${var.docker_image_name}:${formatdate("YYYYMMDDhhmmssZ", timestamp())}"
}
