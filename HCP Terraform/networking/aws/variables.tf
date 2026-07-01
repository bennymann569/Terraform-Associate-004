variable "name_prefix" {
  description = "Prefix for the resources name"
  type        = string
  default     = "taco-wagon"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
}

variable "region" {
  description = "AWS region to deploy resources into"
  type        = string
  default     = "us-east-2"
}

variable "common_tags" {
  description = "Common tags to apply to all resources"
  type        = map(string)
  default     = {}
}
