terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.50"
    }
    azuread = {
      source  = "hashicorp/azuread"
      version = ">=2.50.0"
    }
  }

  required_version = ">= 1.3.0"
}

provider "azurerm" {
  features {}

  # Use Azure CLI authentication
  use_cli = true
}

provider "azuread" {
  # Uses credentials from azurerm provider
}
