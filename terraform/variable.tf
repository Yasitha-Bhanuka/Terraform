variable "region" {
  type        = string
  description = "The region to deploy the Cloud Run service to"
  default     = "asia-southeast1"
}

variable "port" {
  type        = number
  description = "The port of exposed by the Cloud Run service"
  default     = 8080
}
