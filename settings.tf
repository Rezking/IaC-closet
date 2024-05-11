terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.0.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "terraform_state"
    storage_account_name = "terrastate26343"
    container_name       = "terraformstate"
    key                  = "terraform.tfstate"
  }
}

provider "azurerm" {
  features {}
}

