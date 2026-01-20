resource "aws_s3_bucket" "bucket" {
  bucket = var.s3_bucket
  force_destroy = true
}
