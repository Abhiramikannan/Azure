#acr,availability zone,install apache2
Q2.. *Write a Terraform script to:*
* Create a resource group
* Provision a VM in *Availability Zone 2* of Central India
* Attach a public IP
* Install Apache on boot using custom_data




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
resource "azurerm_resource_group" "rg" {
  location   = "centralindia"
  name       = "abhi-rg3"
}
resource "azurerm_container_registry" "acr" {
  location                      = azurerm_resource_group.rg.location
  name                          = "abhiacrexam1"
  public_network_access_enabled = true
  sku                           = "Basic"
  resource_group_name=azurerm_resource_group.rg.name
}

#vnet and subnet
resource "azurerm_virtual_network" "vnet" {
  address_space                  = ["10.0.0.0/16"]
  location                       = azurerm_resource_group.rg.location
  name                           = "abhi-vm-vnet1"
  resource_group_name            = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "subnet" {
  address_prefixes                              = ["10.0.0.0/24"]
  name                                          = "abhi-subnet1"
  private_link_service_network_policies_enabled = true
  resource_group_name                           = azurerm_resource_group.rg.name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
}

#publicip
resource "azurerm_public_ip" "publicip" {
  allocation_method       = "Static"
  ip_version              = "IPv4"
  location                = azurerm_resource_group.rg.location
  name                    = "abhi-vm1-ip"
  resource_group_name     = azurerm_resource_group.rg.name
  sku                     = "Standard"
}

#nsg
resource "azurerm_network_security_group" "nsg" {
  location            = azurerm_resource_group.rg.location
  name                = "abhi-vm-nsg1"
  resource_group_name = azurerm_resource_group.rg.name
  
}
resource "azurerm_network_security_rule" "res-5" {
  access                                     = "Allow"
  description                                = "securityruleforssh"
  destination_address_prefix                 = "*"
  destination_port_range                     = "22"
  direction                                  = "Inbound"
  name                                       = "SSH22abbhi"
  network_security_group_name                = azurerm_network_security_group.nsg.name
  priority                                   = 300
  protocol                                   = "Tcp"
  resource_group_name                        = azurerm_resource_group.rg.name
  source_address_prefix                      = "*"
  source_port_range                          = "*"
}


resource "azurerm_network_interface" "nic" {
  location                       =  azurerm_resource_group.rg.location
  name                           = "abhi-vm1526_z2"
  resource_group_name            = azurerm_resource_group.rg.name
  ip_configuration {
    name                                               = "ipconfig1"
    private_ip_address_allocation                      = "Dynamic"
    public_ip_address_id                               = azurerm_public_ip.publicip.id
    subnet_id                                          = azurerm_subnet.subnet.id
  }
}
resource "azurerm_network_interface_security_group_association" "res-3" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


#vm
resource "azurerm_linux_virtual_machine" "res-1" {
  admin_password                                         = "abhi@12345678" # Masked sensitive attribute
  admin_username                                         = "abhi"
  location                                               = azurerm_resource_group.rg.location
  name                                                   = "abhi-vm"
  network_interface_ids                                  = [azurerm_network_interface.nic.id]
  resource_group_name                                    = azurerm_resource_group.rg.name
  secure_boot_enabled                                    = true
  size                                                   = "Standard_B2s"
  zone                                                   = "2" #for availability zone
  disable_password_authentication                        = false  
  os_disk {
    caching                          = "ReadWrite"
    name                             = "abhi-vm1disk"
    storage_account_type             = "Premium_LRS"
  }
  source_image_reference {
    offer     = "ubuntu-24_04-lts"
    publisher = "canonical"
    sku       = "server"
    version   = "latest"
  }
  custom_data=base64encode(file("install-apache.sh"))  #passing as a file
}
# 9. Output public IP

output "public_ip_address" {
  value = azurerm_public_ip.public_ip.ip_address
}


#install-apache.sh
#!/bin/bash
apt update -y
apt install -y apache2
systemctl enable apache2
systemctl start apache2

