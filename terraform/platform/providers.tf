terraform {
  required_version = ">= 1.5.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.100"
    }
  }

  # For the demo, local state is fine.
  # In production, use Azure Storage Account backend:
  # backend "azurerm" {
  #   resource_group_name  = "rg-fincore-tfstate"
  #   storage_account_name = "stfincoretfstate"
  #   container_name       = "tfstate"
  #   key                  = "platform.tfstate"
  # }
}

provider "azurerm" {
  features {}
}
