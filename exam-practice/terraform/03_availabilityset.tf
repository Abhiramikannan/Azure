#availabilityset
#  Create a Terraform file that:*
#   Launches 2 VMs in the same *Availability Set*
#   Uses the same NIC configuration
#   Applies a Network Security Group allowing only SSH (port 22)

#order: vnet,subnet,nsg, all need count=2
#fixes:
#inside vm block= [azurerm_network_interface.nic[count.index].id]  need []
#inside vm block =availability_set_id = azurerm_availability_set.availset.id
#count used=publicip,nic,association,vm
#${count.index+1} used=publicip,nic-ipconfg,vm-osdisk


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

#nsg
resource "azurerm_network_security_group" "nsg" {
  location            = azurerm_resource_group.rg.location
  name                = "abhi-vm-nsg1"
  resource_group_name = azurerm_resource_group.rg.name
  
}


#use metaarguments and availability set

#avilabilityset
resource "azurerm_availability_set" "availset" {
  location            = azurerm_resource_group.rg.location
  name                = "abhiavailability"
  resource_group_name = azurerm_resource_group.rg.name
  managed=true#imp
  platform_fault_domain_count=2
  platform_update_domain_count=5
}
#publicip
resource "azurerm_public_ip" "publicip" {
  count=2
  allocation_method       = "Static"
  ip_version              = "IPv4"
  location                = azurerm_resource_group.rg.location
  name                    = "abhi-vm${count.index+1}-publicip"
  resource_group_name     = azurerm_resource_group.rg.name
  sku                     = "Standard"
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
  count=2
  location                       =  azurerm_resource_group.rg.location
  name                           = "abhi-nic${count.index+1}-nic"
  resource_group_name            = azurerm_resource_group.rg.name
  ip_configuration {
    name                                               = "ipconfig1${count.index+1}ip"
    private_ip_address_allocation                      = "Dynamic"
    public_ip_address_id                               = azurerm_public_ip.publicip[count.index].id
    subnet_id                                          = azurerm_subnet.subnet.id
  }
}
resource "azurerm_network_interface_security_group_association" "res-3" {
  count=2
  network_interface_id      = azurerm_network_interface.nic[count.index].id 
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#vm
resource "azurerm_linux_virtual_machine" "res-1" {
  count=2
  admin_password                                         = "abhi@12345678" # Masked sensitive attribute
  admin_username                                         = "abhi"
  location                                               = azurerm_resource_group.rg.location
  name                                                   = "abhi-vm${count.index+1}"
  network_interface_ids                                  = [azurerm_network_interface.nic[count.index].id]
  resource_group_name                                    = azurerm_resource_group.rg.name
  secure_boot_enabled                                    = true
  size                                                   = "Standard_B2s"
  #zone                                                   = "2" #for availability zone
  disable_password_authentication                        = false  
  availability_set_id=azurerm_availability_set.availset.id #added
  os_disk {
    caching                          = "ReadWrite"
    name                             = "abhi-disk${count.index+1}"
    storage_account_type             = "Premium_LRS"
  }
  source_image_reference {
    offer     = "ubuntu-24_04-lts"
    publisher = "canonical"
    sku       = "server"
    version   = "latest"
  }
}
