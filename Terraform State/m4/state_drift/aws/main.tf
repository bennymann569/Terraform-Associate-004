provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "logs" {
  bucket_prefix = "tf-state-drift-"
  force_destroy = true
  region        = "us-east-2"
}

output "bucket_name" {
  value = aws_s3_bucket.logs.bucket
}

output "bucket_region" {
  value = aws_s3_bucket.logs.region
}