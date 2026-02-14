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
  }
}
# rm - Resource Manager
provider "azurerm" {
  features {}
}