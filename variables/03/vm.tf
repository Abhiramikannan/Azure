locals {
  vm_size = "Standard_B1s"

  tags = {
    Name = "My Virtual Machine"
    Env  = "Dev"
  }
}

resource "azurerm_resource_group" "main" {
  name     = "abhi-rg4"
  location = "centralindia"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "abhi-Vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "abhi-Subnet"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "nic" {
  name                = "abhi-NIC"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
  }

  tags = {
    Name = "My NIC"
  }
}

resource "azurerm_linux_virtual_machine" "myvm" {
  name                = "abhi-VM"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  size                = local.vm_size
  admin_username      = "azureuser"

  disable_password_authentication = false


  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

   admin_password = "P@ssword1234!"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
    name                 = "myOsDisk"
  }

source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
  tags = local.tags
}
