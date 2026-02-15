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
  }
  # https://developer.hashicorp.com/terraform/language/backend/azurerm
  backend "azurerm" {
    resource_group_name = "rg-terraform-state-dev"
    storage_account_name = "stdvhih8kb07"
    container_name = "tfstate"
    key = "network-dev"
  }
}
# rm - Resource Manager
provider "azurerm" {
  features {}
}