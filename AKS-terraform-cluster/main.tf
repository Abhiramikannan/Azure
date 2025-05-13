#https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster
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

resource "azurerm_resource_group" "example" {
  name     = "abhi-resources"
  location = "south india"
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "abhi-aks"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "abhi-aks"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_a2_v2"
  }

  identity {
    type = "SystemAssigned"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config[0].client_certificate
  sensitive = true
}

output "kube_config" {
  value = azurerm_kubernetes_cluster.example.kube_config_raw

  sensitive = true
}

#https://learn.microsoft.com/en-us/azure/aks/learn/quick-kubernetes-deploy-terraform?pivots=development-environment-azure-cli