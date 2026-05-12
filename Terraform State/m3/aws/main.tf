provider "aws" {
  region = "us-east-2"
}

import {
  to = aws_s3_bucket.example
  id = "tf-import-demo-8d53b592"
}