variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-2"
}

variable "instance_type" {
  description = "The type of EC2 instance"
  type        = string
  default     = "t3.micro"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "subnet_id" {
  description = "The ID of the subnet to deploy resources into"
  type        = string
}