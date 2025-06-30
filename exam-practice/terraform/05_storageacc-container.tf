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


#rg
resource "azurerm_resource_group" "rg" {
  location   = var.location
  name       = "abhi-rg3"
}

#storage acc
resource "azurerm_storage_account" "sa" {
    name="abhistorage9087"
    resource_group_name=azurerm_resource_group.rg.name
    location=var.location
    account_tier="Standard"
    account_replication_type="LRS"

}

#container
resource "azurerm_storage_container" "container" {
  name="abhicont"
  storage_account_id=azurerm_storage_account.sa.id
  container_access_type="blob"
  #container_access_type="private"
}

variable "location" {
  default="centralindia"
  description="location"
  type=string
}

#output
output "storage_account_name" {
  value=azurerm_storage_account.sa.id
}

output "storage_account_container_name" {
  value=azurerm_storage_container.container.id
}


backend.tf
terraform{
    backend "azurerm" {
        resource_group_name="abhi-rg3"
        storage_account_name  = "abhistorage9087"
        container_name        = "abhicont"
        key                   = "terraform.tfstate"
    }
}

pipeline.yml
# Starter pipeline
# Start with a minimal pipeline that you can customize to build and deploy your code.
# Add steps that build, run tests, deploy, and more:
# https://aka.ms/yaml

trigger:
- master

pool:
  name: abhipool
  vmImage: abhi-vm

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
     ARM_SUBSCRIPTION_ID: $(ARM_SUBSCRIPTION_ID)
- task: AzureCLI@2
  inputs:
    azureSubscription: 'abhi-sc1'
    scriptType: 'bash'
    scriptLocation: 'inlineScript'
    inlineScript: |
      az storage blob upload \
        --account-name abhistorage9087 \
        --container-name abhicont \
        --name azure-pipelines.yml \
        --file $(Build.SourcesDirectory)/azure-pipelines.yml 
      
