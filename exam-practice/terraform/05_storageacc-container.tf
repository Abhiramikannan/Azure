terraform {
  required_providers {
    azurerm = {
      source  = "azurerm"
      version = "4.24.0"
    }
  }
}
provider "azurerm" {
  features {}
}


#rg
resource "azurerm_resource_group" "rg" {
  location   = var.location
  name       = "abhi-rg3"
}

#storage acc
resource "azurerm_storage_account" "sa" {
    name="abhistorage9087"
    resource_group_name=azurerm_resource_group.rg.name
    location=var.location
    account_tier="Standard"
    account_replication_type="LRS"

}

#container
resource "azurerm_storage_container" "container" {
  name="abhicont"
  storage_account_id=azurerm_storage_account.sa.id
  container_access_type="blob"
  #container_access_type="private"
}

variable "location" {
  default="centralindia"
  description="location"
  type=string
}

#output
output "storage_account_name" {
  value=azurerm_storage_account.sa.id
}

output "storage_account_container_name" {
  value=azurerm_storage_container.container.id
}
