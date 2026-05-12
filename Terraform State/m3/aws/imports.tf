# __generated__ by Terraform
# Please review these resources and move them into your main configuration files.

# __generated__ by Terraform from "tf-import-demo-8d53b592"
resource "aws_s3_bucket" "example" {
  bucket              = "tf-import-demo-8d53b592"
  force_destroy       = true
  object_lock_enabled = false
  region              = "us-east-2"
}
