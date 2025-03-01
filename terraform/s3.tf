resource "random_string" "bucket_suffix" {
  length  = 8
  special = false
  upper   = false
}

resource "aws_s3_bucket" "data_bucket" {
  bucket = "${var.app_name}-data-${random_string.bucket_suffix.result}"
}
