aim: create a vm using terraform
steps involved:
    rg,vnet,subnet,publicip,nsg,association,nic,vm
got errorslike:
    subscription id required (add variable in pipeline subscription and give the subscription id ,and give env and give)
    terraform dont have permssions so dont give resource group

pipeline:

        repo create ,add 
        create agent pool   
        create service connection ,dont give resource group,else->error -terraform doesnt have any permssion
        create pipeline-install az client,terraform commands,added the subscription id in variables
        env:
        
          ARM_SUBSCRIPTION_ID: $(subscription)


code:
====================================
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
  location   = "eastus2"
  name       = "abhi-rg2"
}

resource "azurerm_virtual_network" "vnet" {
  address_space                  = ["10.0.0.0/16"]
  location                       = azurerm_resource_group.rg.location
  name                           = "abhi-vm-vnet"
  resource_group_name            = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_resource_group.rg
  ]
}


resource "azurerm_subnet" "subnet" {
  address_prefixes                              = ["10.0.0.0/24"]
  name                                          = "abhi-subnet"
  resource_group_name                           = azurerm_resource_group.rg.name
  virtual_network_name                          = "abhi-vm-vnet"
  depends_on = [
    azurerm_virtual_network.vnet
  ]
}


resource "azurerm_public_ip" "res-6" {
  allocation_method       = "Static"
  location                = azurerm_resource_group.rg.location
  name                    = "abhi-vm-ip"
  resource_group_name     = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_resource_group.rg
  ]
}

resource "azurerm_network_security_group" "nsg" {
  location            = azurerm_resource_group.rg.location
  name                = "abhi-vm-nsg"
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_network_interface_security_group_association" "res-3" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
}


resource "azurerm_network_interface" "nic" {
  location                       = azurerm_resource_group.rg.location
  name                           = "abhi-nic"
  resource_group_name            = azurerm_resource_group.rg.name
  ip_configuration {
    name                                               = "ipconfig1"
    private_ip_address_allocation                      = "Dynamic"
    public_ip_address_id                               = azurerm_public_ip.res-6.id
    subnet_id                                          = azurerm_subnet.subnet.id
  }
}

resource "azurerm_linux_virtual_machine" "res-1" {
  admin_password                                         = "Abhi@12345678" # Masked sensitive attribute
  admin_username                                         = "abhi"
  computer_name                                          = "abhi-vm"
  location                                               = azurerm_resource_group.rg.location
  name                                                   = "abhi-vm1"
  network_interface_ids                                  = [azurerm_network_interface.nic.id]
  resource_group_name                                    = "abhi-rg"
  size                                                   = "Standard_B2s"
  disable_password_authentication                        = false
  os_disk {
    caching                          = "ReadWrite"
    name                             = "abhi-vm_OsDisk"
    storage_account_type             = "Premium_LRS"
  }
  source_image_reference {
    offer     = "ubuntu-24_04-lts"
    publisher = "canonical"
    sku       = "server"
    version   = "latest"
  }
}


pipeline code:
==============================
# Starter pipeline
# Start with a minimal pipeline that you can customize to build and deploy your code.
# Add steps that build, run tests, deploy, and more:
# https://aka.ms/yaml

trigger:
- master

pool:
  name: abhipool
  vmImage: abhi-vm

#search azurecli and give command 
steps:
- task: Bash@3
  inputs:
    targetType: 'inline'
    script: | 
       curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
       az version

- task: AzureCLI@2
  inputs:
    azureSubscription: 'abhi-sc1'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      terraform init
      terraform plan -out=tfplan
      terraform apply --auto-approve tfplan
  env:
    ARM_SUBSCRIPTION_ID: $(subscription)
    #give subscription id in variable and click variables and copy and paste here in above line it will paste like $(subscription)
