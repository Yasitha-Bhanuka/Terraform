resource "google_storage_bucket" "demo-bucket" {
  name          = "yasitha-gcs-demo"
  location      = "asia-southeast1"
  force_destroy = true

  soft_delete_policy {
    retention_duration_seconds = 0
  }
}

resource "google_storage_bucket_object" "demo-object" {
  name    = "demo-object"
  bucket  = google_storage_bucket.demo-bucket.name
  content = module.api1.url
}
