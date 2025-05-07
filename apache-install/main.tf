provider "azurerm" {
  features {}
}
 
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.0"
    }
  }
}
 
resource "azurerm_resource_group" "rg" {
  name     = "abhi-vmss-rg"
  location = "Central India "
}
 
# VNET and Subnets
resource "azurerm_virtual_network" "vnet" {
  name                = "abhi-vmss-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}
 
resource "azurerm_subnet" "public" {
  name                 = "abhi-pub-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}
 
resource "azurerm_subnet" "private" {
  name                 = "abhi-private-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
}
 
# Public IP for Load Balancer
resource "azurerm_public_ip" "lb_ip" {
  name                = "abhi-lb-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
 
# Load Balancer
resource "azurerm_lb" "lb" {
  name                = "abhi-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"
 
  frontend_ip_configuration {
    name                          = "abhiLoadBalancer"
    public_ip_address_id          = azurerm_public_ip.lb_ip.id
    private_ip_address_allocation = "Dynamic"
  }
}
 
# Backend Pool
resource "azurerm_lb_backend_address_pool" "backend_pool" {
  name            = "abhi-backend-pool"
  loadbalancer_id = azurerm_lb.lb.id
}
 
# Health Probe
resource "azurerm_lb_probe" "http_probe" {
  name                = "abhi-http-probe"
  loadbalancer_id     = azurerm_lb.lb.id
  protocol            = "Tcp"
  port                = 80
  interval_in_seconds = 5
  # number_of_probes    = 2
}
 
# Load Balancer Rule
resource "azurerm_lb_rule" "http" {
  name                            = "abhi-http-rule"
  loadbalancer_id                 = azurerm_lb.lb.id
  frontend_ip_configuration_name = "abhiLoadBalancer"
  backend_address_pool_ids        = [azurerm_lb_backend_address_pool.backend_pool.id]
  protocol                        = "Tcp"
  frontend_port                   = 80
  backend_port                    = 80
  probe_id                        = azurerm_lb_probe.http_probe.id
}
 
resource "azurerm_network_security_group" "web_nsg" {
  name                = "abhi-nsg"
  location            = resource.azurerm_resource_group.rg.location
  resource_group_name = resource.azurerm_resource_group.rg.name
 
  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}
 
resource "azurerm_subnet_network_security_group_association" "nsg_assoc" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.web_nsg.id
}
 
# Image Version (adjust as per your gallery setup)
data "azurerm_shared_image_version" "abhi-image" {
  name                = "0.0.1"
  image_name          = "abhi-image"
  gallery_name        = "abhi_images"
  resource_group_name = "abhi-resource-group"
}
 
# VMSS
resource "azurerm_linux_virtual_machine_scale_set" "vmss" {
  name                = "abhi-apache-vmss"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard_B1s"
  instances           = 2
  admin_username      = "azureuser"
  source_image_id     = data.azurerm_shared_image_version.abhi-image.id
    secure_boot_enabled = true
 
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
 
  admin_ssh_key {
    username   = "azureuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }
 
  upgrade_mode = "Manual"
 
  network_interface {
    name    = "abhi-vmss-nic"
    primary = true
 
    ip_configuration {
      name      = "internal"
      subnet_id = azurerm_subnet.private.id
 
      load_balancer_backend_address_pool_ids = [
        azurerm_lb_backend_address_pool.backend_pool.id
      ]
    }
  }
 
  health_probe_id = azurerm_lb_probe.http_probe.id
}