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

resource "azurerm_lb" "lb_interne" {
  name                = "lb_interne"
  location            = var.location
  resource_group_name = var.rg

  frontend_ip_configuration {
    name                 = "lb_interne_frontend"
    subnet_id = azurerm_subnet.subnet-3.id
  }

  tags = {
    Brief = var.brief_tag
    Owner = "Jess"
  }
}

resource "azurerm_lb_backend_address_pool" "lb_backend" {
  loadbalancer_id = azurerm_lb.lb_interne.id
  name            = "BackEndAddressPool"
}


resource "azurerm_lb_rule" "lbrule" {
  loadbalancer_id                = azurerm_lb.lb_interne.id
  name                           = "LBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "lb_interne_frontend"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend.id]
}
