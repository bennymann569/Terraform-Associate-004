data "aws_availability_zones" "available" {
  state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "6.6.1"

  name = var.name_prefix
  cidr = var.vpc_cidr

  azs            = slice(data.aws_availability_zones.available.names, 0, 1)
  public_subnets = [var.subnet_cidr]

  enable_dns_hostnames = true
  map_public_ip_on_launch = true
  

  enable_nat_gateway = false
  enable_vpn_gateway = false

  tags = var.common_tags
}
