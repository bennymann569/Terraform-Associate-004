provider "aws" {
  region = "us-east-2"
}

resource "aws_s3_bucket" "logs" {
  bucket              = "tf-import-demo-ff75b536"
  force_destroy       = true
  object_lock_enabled = false
  region              = "us-east-2"
}