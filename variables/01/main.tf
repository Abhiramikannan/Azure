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
resource "azurerm_resource_group" "rg" {
  name     = "myrg${var.name}"
  location = "centralus"
}

output "name"{
  value=azurerm_resource_group.rg.name
}