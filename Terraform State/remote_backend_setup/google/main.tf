terraform {
  required_version = ">= 1.6.0"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 7.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

variable "project_id" {
  type        = string
  description = "GCP project ID in which to create the state bucket."
}

variable "location" {
  type    = string
  default = "US"
}

provider "google" {
  project = var.project_id
}

resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
  numeric = true
}

resource "google_storage_bucket" "tf_state" {
  name                        = "tf-state-${var.project_id}-${random_string.suffix.result}"
  location                    = var.location
  force_destroy               = true
  uniform_bucket_level_access = true
  public_access_prevention    = "enforced"

  versioning {
    enabled = true
  }
}

output "backend_info" {
  value = {
    bucket = google_storage_bucket.tf_state.name
    prefix = "m2"
  }
}
