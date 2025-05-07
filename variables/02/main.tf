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
  name     ="${var.rgname}myrg${var.number_type}"
  location = "centralus"
  tags=var.tags
}

output "bool_type"{
  value=var.boolean_type
}
output "list_type"{
  value=var.list_type
}
output "map"{
  value=var.map_type
}
output "object"{
  value=var.object_type
}
output "tuple_type"{
  value=var.tuple_type
}
output "set_example"{
  value=var.set_example
}
output "map_of_objects"{
  value=var.map_of_objects
}
output "list_of_objects"{
  value=var.list_of_objects
}

