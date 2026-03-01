resource "google_storage_bucket" "demo-bucket" {
  name          = "yasitha-gcs-demo"
  location      = var.region
  force_destroy = true

  soft_delete_policy {
    retention_duration_seconds = 0
  }
}
