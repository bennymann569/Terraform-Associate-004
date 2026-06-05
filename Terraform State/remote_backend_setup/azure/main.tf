terraform {
  required_version = ">= 1.6.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

variable "location" {
  type    = string
  default = "eastus2"
}

resource "random_string" "suffix" {
  length  = 8
  upper   = false
  special = false
  numeric = true
}

resource "azurerm_resource_group" "tf_state" {
  name     = "rg-tf-state-${random_string.suffix.result}"
  location = var.location
}

resource "azurerm_storage_account" "tf_state" {
  name                            = "tfstate${random_string.suffix.result}"
  resource_group_name             = azurerm_resource_group.tf_state.name
  location                        = azurerm_resource_group.tf_state.location
  account_tier                    = "Standard"
  account_replication_type        = "LRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false

  blob_properties {
    versioning_enabled = true
  }
}

resource "azurerm_storage_container" "tf_state" {
  name                  = "tfstate"
  storage_account_id    = azurerm_storage_account.tf_state.id
  container_access_type = "private"
}

output "backend_info" {
  value = {
    resource_group_name  = azurerm_resource_group.tf_state.name
    storage_account_name = azurerm_storage_account.tf_state.name
    container_name       = azurerm_storage_container.tf_state.name
    key                  = "m2/terraform.tfstate"
  }
}
