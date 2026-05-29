terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }
  }
  cloud {
    
    organization = "ned-0527-org"

    workspaces {
      name = "taco-wagon-networking"
    }
  }
}

provider "aws" {
  region = var.region
}
