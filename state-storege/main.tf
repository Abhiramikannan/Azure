#storage account -backend configuration
# after backend configured all other creations will be updated in the tf state file of storage acc
#added vm and applied
#when i give apply -locked
 
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
  # backend "azurerm" {
  #     resource_group_name  = "abhi-tfstate-rg"
  #     storage_account_name = "abhistoragetfstate03urc"
  #     container_name       = "abhitfstate"
  #     key                  = "terraform.tfstate"
  # }

}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "state-demo-secure" {
  name     = "abhi-state-demo"
  location = "eastus"
}

resource "random_string" "resource_code" {
  length  = 5
  special = false
  upper   = false
}

resource "azurerm_resource_group" "tfstate" {
  name     = "abhi-tfstate-rg"
  location = "East US"
}

resource "azurerm_storage_account" "tfstate" {
  name                     = "abhistoragetfstate${random_string.resource_code.result}"
  resource_group_name      = azurerm_resource_group.tfstate.name
  location                 = azurerm_resource_group.tfstate.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  allow_nested_items_to_be_public = false

  tags = {
    environment = "staging"
  }
}

resource "azurerm_storage_container" "tfstate" {
  name                  = "abhitfstate"
  storage_account_name  = azurerm_storage_account.tfstate.name
  container_access_type = "private"
}

# #change only from here only..dont change backend configuration
# #we can see the state file is locked if someone else apply is happneing
# #when apply - destroy the someone else work and replace our work
# resource "azurerm_resource_group" "example" {
#   name     = "abhistate-demo"
#   location = "centralindia"
# }
 
# resource "azurerm_virtual_network" "example" {
#   name                = "abhi-network"
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
# }
 
# resource "azurerm_subnet" "example" {
#   name                 = "abhi-subnet"
#   resource_group_name  = azurerm_resource_group.example.name
#   virtual_network_name = azurerm_virtual_network.example.name
#   address_prefixes     = ["10.0.2.0/24"]
# }
 
# resource "azurerm_public_ip" "public_ip" {
#   name                = "abhi-public-ip"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   allocation_method = "Static"
# }
 
# resource "azurerm_network_interface" "example" {
#   name                = "abhi-nic"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
 
#   ip_configuration {
#     name                          = "internal"
#     subnet_id                     = azurerm_subnet.example.id
#     private_ip_address_allocation = "Dynamic"
#     public_ip_address_id          = azurerm_public_ip.public_ip.id
#   }
# }
 
 
# resource "azurerm_linux_virtual_machine" "example" {
#   name                = "abhi-machine"
#   resource_group_name = azurerm_resource_group.example.name
#   location            = azurerm_resource_group.example.location
#   size                = "Standard_F2"
#   admin_username      = "adminuser"
#   network_interface_ids = [
#     azurerm_network_interface.example.id,
#   ]
 
#   admin_ssh_key {
#     username   = "adminuser"
#     public_key = file("~/.ssh/id_rsa.pub")
#   }
 
#   os_disk {
#     caching              = "ReadWrite"
#     storage_account_type = "Standard_LRS"
#   }
 
#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "0001-com-ubuntu-server-jammy"
#     sku       = "22_04-lts"
#     version   = "latest"
#   }
 
#   tags = {
#     Name = "dev"
#   }
# }