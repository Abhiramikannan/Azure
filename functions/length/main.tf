#length
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
 list_length   = length([10, 20, 30])
 string_length = length("abcdefghij")
}

output "lengths" {
 value = format("List length is %d. String length is %d", local.list_length, local.string_length)
}