resource "google_storage_bucket" "demo-bucket" {
  name          = "yasitha-gcs-demo"
  location      = "asia-southeast1"
  force_destroy = true

  soft_delete_policy {
    retention_duration_seconds = 0
  }
}
