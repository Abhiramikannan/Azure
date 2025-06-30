# 9. *Modify your existing Terraform script to:*
# Create an additional VM in a different subnet
# Ensure both VMs can ping each other (i.e., intra-subnet communication is enabled)
#  Use Terraform variables for VM size and location

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
  location   = var.location
  name       = "abhi-rg3"
}


#vnet and subnet
resource "azurerm_virtual_network" "vnet" {
  address_space                  = ["10.0.0.0/16"]
  location                       = azurerm_resource_group.rg.location
  name                           = "abhi-vm-vnet1"
  resource_group_name            = azurerm_resource_group.rg.name
}
resource "azurerm_subnet" "subnet1" {
  address_prefixes                              = ["10.0.0.0/24"]
  name                                          = "abhi-subnet1"
  private_link_service_network_policies_enabled = true
  resource_group_name                           = azurerm_resource_group.rg.name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
}

resource "azurerm_subnet" "subnet2" {
  address_prefixes                              = ["10.0.1.0/24"]
  name                                          = "abhi-subnet2"
  private_link_service_network_policies_enabled = true
  resource_group_name                           = azurerm_resource_group.rg.name
  virtual_network_name                          = azurerm_virtual_network.vnet.name
}
#nsg
resource "azurerm_network_security_group" "nsg" {
  location            = azurerm_resource_group.rg.location
  name                = "abhi-nsg"
  resource_group_name = azurerm_resource_group.rg.name
  
}
resource "azurerm_network_security_rule" "allow_ssh" {
  name                        = "Allow-SSH"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}
resource "azurerm_network_security_rule" "allow_icmp" {
  name                        = "Allow-ICMP"
  priority                    = 110
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Icmp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  resource_group_name         = azurerm_resource_group.rg.name
  network_security_group_name = azurerm_network_security_group.nsg.name
}

#publicip
resource "azurerm_public_ip" "publicip1" {
  allocation_method       = "Static"
  ip_version              = "IPv4"
  location                = azurerm_resource_group.rg.location
  name                    = "abhi-vm1-publicip"
  resource_group_name     = azurerm_resource_group.rg.name
  sku                     = "Standard"
}
#publicip
resource "azurerm_public_ip" "publicip2" {
  allocation_method       = "Static"
  ip_version              = "IPv4"
  location                = azurerm_resource_group.rg.location
  name                    = "abhi-vm2-publicip"
  resource_group_name     = azurerm_resource_group.rg.name
  sku                     = "Standard"
}



resource "azurerm_network_interface" "nic1" {
  location                       =  azurerm_resource_group.rg.location
  name                           = "abhi-nic1"
  resource_group_name            = azurerm_resource_group.rg.name
  ip_configuration {
    name                                               = "ipconfig2"
    private_ip_address_allocation                      = "Dynamic"
    public_ip_address_id                               = azurerm_public_ip.publicip1.id
    subnet_id                                          = azurerm_subnet.subnet1.id
  }
}

resource "azurerm_network_interface" "nic2" {
  location                       =  azurerm_resource_group.rg.location
  name                           = "abhi-nic2"
  resource_group_name            = azurerm_resource_group.rg.name
  ip_configuration {
    name                                               = "ipconfig2ip"
    private_ip_address_allocation                      = "Dynamic"
    public_ip_address_id                               = azurerm_public_ip.publicip2.id
    subnet_id                                          = azurerm_subnet.subnet2.id
  }
}
resource "azurerm_network_interface_security_group_association" "res-3" {

  network_interface_id      = azurerm_network_interface.nic1.id 
  network_security_group_id = azurerm_network_security_group.nsg.id
}

resource "azurerm_network_interface_security_group_association" "res-31" {

  network_interface_id      = azurerm_network_interface.nic2.id 
  network_security_group_id = azurerm_network_security_group.nsg.id
}
#vm
resource "azurerm_linux_virtual_machine" "res-1" {
  admin_password                                         = "abhi@12345678" # Masked sensitive attribute
  admin_username                                         = "abhi"
  location                                               = azurerm_resource_group.rg.location
  name                                                   = "abhi-vm1"
  network_interface_ids                                  = [azurerm_network_interface.nic1.id]
  resource_group_name                                    = azurerm_resource_group.rg.name
  secure_boot_enabled                                    = true
  size                                                   = var.vm_size
  #zone                                                   = "2" #for availability zone
  disable_password_authentication                        = false  
  os_disk {
    caching                          = "ReadWrite"
    name                             = "abhi-disk1"
    storage_account_type             = "Premium_LRS"
  }
  source_image_reference {
    offer     = "ubuntu-24_04-lts"
    publisher = "canonical"
    sku       = "server"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "vm2" {
  admin_password                                         = "abhi@12345678" # Masked sensitive attribute
  admin_username                                         = "abhi"
  location                                               = azurerm_resource_group.rg.location
  name                                                   = "abhi-vm2"
  network_interface_ids                                  = [azurerm_network_interface.nic2.id]
  resource_group_name                                    = azurerm_resource_group.rg.name
  secure_boot_enabled                                    = true
  size                                                   = var.vm_size
  #zone                                                   = "2" #for availability zone
  disable_password_authentication                        = false  
  os_disk {
    caching                          = "ReadWrite"
    name                             = "abhi-disk2"
    storage_account_type             = "Premium_LRS"
  }
  source_image_reference {
    offer     = "ubuntu-24_04-lts"
    publisher = "canonical"
    sku       = "server"
    version   = "latest"
  }
}


variable "location" {
    type=string
    default="centralindia"
    description="vm location"
}

variable "vm_size" {
    type= string
    default="Standard_B2s"
    description="vm_size"
}

output "vm1_public_ip" {
  value = azurerm_public_ip.publicip1.ip_address
}

output "vm2_public_ip" {
  value = azurerm_public_ip.publicip2.ip_address
}
