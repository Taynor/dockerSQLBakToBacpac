terraform {
required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.57.0"
    }
  }
}

provider "azurerm" {
  features {}
  skip_provider_registration = true
}

resource "random_string" "random" {
  length  = 16
  special = false
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group
  location = var.azure_location
}

resource "azurerm_virtual_network" "avn" {
  name                = var.vnet
  resource_group_name = var.resource_group
  location            = var.azure_location
  address_space       = ["10.10.10.0/24"]
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_subnet" "as" {
    name                                           = var.container_subnet
    address_prefixes                               = ["10.10.10.0/25"]
    resource_group_name                            = var.resource_group
    virtual_network_name                           = azurerm_virtual_network.avn.name
    enforce_private_link_endpoint_network_policies = true
    depends_on                                     = [azurerm_resource_group.rg, azurerm_virtual_network.avn]
}

resource "azurerm_container_registry" "acr" {
  name                = "tfcontainerregistry${lower(random_string.random.result)}"
  resource_group_name = var.resource_group
  location            = var.azure_location
  sku                 = "Premium"
  depends_on          = [azurerm_resource_group.rg]
}

resource "azurerm_storage_account" "asa" {
  name                      = var.storage_account
  resource_group_name       = var.resource_group
  location                  = var.azure_location
  account_tier              = "Standard"
  account_replication_type  = "LRS"
  account_kind              = "StorageV2"
  min_tls_version           = "TLS1_2"
  enable_https_traffic_only = true
  depends_on                = [azurerm_resource_group.rg]
}

data "azurerm_storage_account_sas" "asas" {
  connection_string = azurerm_storage_account.asa.primary_connection_string
  https_only        = true
  signed_version    = "2017-07-29"
  resource_types {
    service   = true
    container = false
    object    = false
  }
  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }
  start  = "2021-07-01T00:00:00Z"
  expiry = "2022-07-01T00:00:00Z"
  permissions {
    read    = true
    write   = true
    delete  = false
    list    = false
    add     = true
    create  = true
    update  = false
    process = false
  }
  depends_on = [azurerm_storage_account.asa]
}

resource "azurerm_storage_share" "ass" {
  name                 = var.storage_share
  storage_account_name = azurerm_storage_account.asa.name
  quota                = 10
  depends_on           = [azurerm_storage_account.asa] 
}

resource "azurerm_private_endpoint" "ape_registry" {
  name                = var.private_endpoint_registry
  location            = var.azure_location
  resource_group_name = var.resource_group
  subnet_id           = azurerm_subnet.as.id

  private_service_connection {
    name                           = var.private_service_connection_registry
    private_connection_resource_id = azurerm_container_registry.acr.id
    subresource_names              = [ "registry" ]
    is_manual_connection           = false
  }
  depends_on = [azurerm_subnet.as, azurerm_container_registry.acr]
}

resource "azurerm_private_endpoint" "ape_storage" {
  name                = var.private_endpoint_storage
  location            = var.azure_location
  resource_group_name = var.resource_group
  subnet_id           = azurerm_subnet.as.id

  private_service_connection {
    name                           = var.private_service_connection_storage
    private_connection_resource_id = azurerm_storage_account.asa.id
    subresource_names              = [ "blob" ]
    is_manual_connection           = false
  }
  depends_on = [azurerm_subnet.as, azurerm_storage_account.asa]
}

resource "azurerm_private_dns_zone" "apdz_registry" {
  name                = var.private_dns_zone_registry
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_resource_group.rg, azurerm_private_endpoint.ape_registry]
}

resource "azurerm_private_dns_zone" "apdz_storage" {
  name                = var.private_dns_zone_storage
  resource_group_name = azurerm_resource_group.rg.name
  depends_on          = [azurerm_resource_group.rg, azurerm_private_endpoint.ape_storage]
}

resource "azurerm_private_dns_zone_virtual_network_link" "apdzvnl_registry" {
  name                  = var.private_dns_zone_virtual_network_link_registry
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.apdz_registry.name
  virtual_network_id    = azurerm_virtual_network.avn.id
  depends_on            = [azurerm_resource_group.rg, azurerm_virtual_network.avn, azurerm_private_endpoint.ape_registry, azurerm_private_dns_zone.apdz_registry]
}

resource "azurerm_private_dns_zone_virtual_network_link" "apdzvnl_storage" {
  name                  = var.private_dns_zone_virtual_network_link_storage
  resource_group_name   = var.resource_group
  private_dns_zone_name = azurerm_private_dns_zone.apdz_storage.name
  virtual_network_id    = azurerm_virtual_network.avn.id
  depends_on            = [azurerm_resource_group.rg, azurerm_virtual_network.avn, azurerm_private_endpoint.ape_storage, azurerm_private_dns_zone.apdz_storage]
}