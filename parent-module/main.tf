#calling child from parent
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}
 
provider "azurerm" {
  features {}
}
 
module "myvm" {
    source = "./child-module"
    vm_count=2
    environment="dev"
    location="East US"
    cidr="10.0.0.0"
}

output "azurerm_public_ip" {
  value = module.myvm.azurerm_public_ip
}
