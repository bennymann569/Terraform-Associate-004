provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "logs" {
  bucket_prefix = "tf-resource-drift-"
  force_destroy = true
  region        = "us-east-2"

  tags = {
    Environment = "Development"
  }
}

output "bucket_name" {
  value = aws_s3_bucket.logs.bucket
}

output "bucket_region" {
  value = aws_s3_bucket.logs.region
}