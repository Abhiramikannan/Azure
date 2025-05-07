provider "azurerm" {

  features {}

}

terraform {

  required_providers {

    azurerm = {

      source = "hashicorp/azurerm"

      version = "~> 3.0"

    }
  }

}

data "azurerm_resource_group" "example" {

  name = "abhi-resource-group"

}

output "id" {

  value = data.azurerm_resource_group.example.id

}

resource "azurerm_virtual_network" "example" {

  name = "example-network"

  location = data.azurerm_resource_group.example.location

  resource_group_name = data.azurerm_resource_group.example.name

  address_space = ["10.0.0.0/16"]

}

