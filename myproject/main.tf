terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
  required_version = ">=1.0"
}

provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "example" {
  name     = "abhi-resources"
  location = "south india"
}

resource "azurerm_virtual_network" "vnet" {
  name                = "abhi-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "aks_subnet" {
  name                 = "aks-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_subnet" "sql_subnet" {
  name                 = "sql-subnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.2.0/24"]
  private_endpoint_network_policies_enabled = false
}

resource "random_id" "unique" {
  byte_length = 8
}

resource "azurerm_mssql_server" "sql" {
  name                         = "abhi-sqlserver-${substr(random_id.unique.hex, 0, 8)}"
  resource_group_name          = azurerm_resource_group.example.name
  location                     = azurerm_resource_group.example.location
  version                      = "12.0"
  administrator_login          = "sqladmin"
  administrator_login_password = "yourPassword123!"
}

resource "azurerm_mssql_database" "db" {
  name          = "abhi-database"
  server_id     = azurerm_mssql_server.sql.id
  sku_name      = "S0"
}

resource "azurerm_private_endpoint" "sql_pe" {
  name                = "sql-private-endpoint"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  subnet_id           = azurerm_subnet.sql_subnet.id

  private_service_connection {
    name                           = "sql-pe-connection"
    private_connection_resource_id = azurerm_mssql_server.sql.id
    subresource_names              = ["sqlServer"]
    is_manual_connection           = false
  }
}

# # Create the Azure Container Registry (ACR)
# resource "azurerm_container_registry" "acr" {
#   name                = "abhiacr"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   sku                 = "Basic"
#   admin_enabled       = true
# }

# Create the AKS cluster
resource "azurerm_kubernetes_cluster" "aks" {
  name                = "abhi-aks-cluster"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "abhiaks"

  default_node_pool {
    name       = "default"
    node_count = 3
    vm_size    = "Standard_a2_v2"
    vnet_subnet_id = azurerm_subnet.aks_subnet.id
  }

  identity {
    type = "SystemAssigned"
  }
    network_profile {
    network_plugin    = "azure"
    service_cidr      = "10.1.0.0/16"     # ✅ DIFFERENT from your VNet (10.0.0.0/16)
    dns_service_ip    = "10.1.0.10"       # inside service_cidr
    docker_bridge_cidr = "172.17.0.1/16"
  }

  # Attach the ACR to the AKS cluster
  # acr {
  #   server_url = azurerm_container_registry.acr.login_server
  # }
}

#created aks,sql server,sql database,different subnet for aks and sql

