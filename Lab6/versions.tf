terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 4.60.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.8.1"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 3.7.0"
    }
  }
  # https://developer.hashicorp.com/terraform/language/backend/azurerm
  backend "azurerm" {
    resource_group_name = "rg-terraform-state-dev"
    storage_account_name = "stdvhih8kb07"
    container_name = "tfstate"
    key = "linuxvm-dev"
  }
}
# rm - Resource Manager
provider "azurerm" {
  features {
    key_vault {
      purge_soft_deleted_secrets_on_destroy = true
      recover_soft_deleted_secrets          = true
    }
  }
}