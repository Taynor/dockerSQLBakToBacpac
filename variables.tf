variable "azure_location" {
   type    = string
   default = "uksouth"
}
variable "resource_group" {
    type    = string
    default = "tfcontainersql"
}
variable "storage_account" {
   type    = string
   default = "tfcontainerstorage"
}
variable "vnet" {
   type    = string
   default = "tfcontainervnet"
}
variable "container_subnet" {
    type    = string 
    default = "tfcontainersubnet"
}
variable "container_registry" {
    type    = string
    default = "tfcontainerregistry"
}
variable "private_endpoint_registry" {
    type    = string
    default = "tfregistryprivateendpoint"
}
variable "private_endpoint_storage" {
    type    = string
    default = "tfstorageprivateendpoint"
}
variable "storage_share" {
    type    = string
    default = "tfstorageshare"
}
variable "private_service_connection_registry" {
    type    = string
    default = "tfprivateserviceconnectionregistry"
}
variable "private_service_connection_storage" {
    type    = string
    default = "tfprivateserviceconnectionstorage"
}
variable "private_dns_zone_registry" {
    type    = string
    default = "privatelink.azurecr.io"
}
variable "private_dns_zone_storage" {
    type    = string
    default = "privatelink.blob.core.windows.net"
}
variable "private_dns_zone_virtual_network_link_registry" {
    type    = string
    default = "tfprivatednszonevirtualnetworklinkregistry"
}
variable "private_dns_zone_virtual_network_link_storage" {
    type    = string
    default = "tfprivatednszonevirtualnetworklinkstorage"
}