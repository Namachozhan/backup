terraform {
  required_version = ">=1.0"

  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.0"
    }
    null = {
      source  = "hashicorp/null"
      version = "~>3.0"
    }
  }
}


  
  provider "azurerm" {
  client_id       = "73543342-236a-4697-be03-b7d63fe63d2f"
  client_secret   = "FYZ8Q~Rc~Yy.sFkX1RcHzKLI9Ljtj8N~mJVHVbZT"
  tenant_id       = "2e87af94-6452-4baf-a6bf-12bf6ea740fd"
  subscription_id = "e67caa01-5529-4f70-a8cd-44493f2859a4"
  features {}
  skip_provider_registration = true
}


provider "null" {}
