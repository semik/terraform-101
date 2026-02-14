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
}
# rm - Resource Manager
provider "azurerm" {
  features {}

  # enviroment variable might be ARM_SUBSCRIPTION_ID I'm quite confused why not begin wih TF_VAR_
  subscription_id = "e4ea7e96-4993-4602-bc68-0c202688b32f"
}