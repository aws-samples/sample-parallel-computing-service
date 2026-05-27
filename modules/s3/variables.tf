variable "project" {
  type        = string
  description = "The project name."
  default     = null
}

variable "s3_bucket" {
  description = "S3 bucket name"
  type        = string
}
