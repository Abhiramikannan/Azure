#formatlist

terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version=">=1.0"
}
 
provider "azurerm" {
  features {}
}
locals {
 format_list = formatlist("Hello, %s!", ["A", "B", "C"])
}

output "format_list" {
 value = local.format_list
}