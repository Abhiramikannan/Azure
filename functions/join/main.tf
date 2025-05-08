#Join(separator, list)
# This function creates a string by concatenating together all elements of a list and a separator.
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
 join_string = join(",", ["a", "b", "c"])
}

output "join_string" {
 value = local.join_string
}