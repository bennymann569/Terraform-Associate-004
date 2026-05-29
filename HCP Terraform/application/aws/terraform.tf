terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.0"
    }

    tfe = {
      source  = "hashicorp/tfe"
      version = "~> 0.0"
    }
  }

  cloud {
    
    organization = "ned-0527-org"

    workspaces {
      name = "taco-wagon-app"
      project = "taco-wagon"
    }
  }
}

provider "aws" {
  region = var.region
}
