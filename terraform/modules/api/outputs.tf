output "url" {
  value       = google_cloud_run_service.yasitha_service.status[0].url
  description = "The URL of the deployed Cloud Run service"
}
