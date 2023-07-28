terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.63.0"
    }
  }
}
provider "azurerm" {
  features {}
  skip_provider_registration = "true"
}

resource "azurerm_virtual_network" "vnet-1" {
  name                = "vnet-1"
  address_space       = ["10.0.0.0/26"]
  resource_group_name = var.rg
  location            = var.location
}

resource "azurerm_subnet" "subnet-1" {
  name                 = "subnet-1"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["10.0.0.0/28"]
}

resource "azurerm_subnet" "subnet-2" {
  name                 = "subnet-2"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["10.0.0.16/28"]
}

resource "azurerm_subnet" "subnet-3" {
  name                 = "subnet-3"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["10.0.0.32/28"]
}

resource "azurerm_subnet" "subnet-4" {
  name                 = "subnet-4"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["10.0.0.48/28"]
}
resource "azurerm_public_ip" "publiclb-ip" {
  name                = "publiclb-ip"
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = "Static"
}

resource "azurerm_lb" "publiclb" {
  name                = "publiclb"
  resource_group_name = var.rg
  location            = var.location

  frontend_ip_configuration {
    name                 = "publiclb-ip-association"
    public_ip_address_id = azurerm_public_ip.publiclb-ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "publiclb-backend" {
loadbalancer_id = azurerm_lb.publiclb.id
name            = "publiclb-backend"
}

