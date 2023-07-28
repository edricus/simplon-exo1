resource "azurerm_virtual_network" "vnet-1" {
  name                = "vnet-1"
  address_space       = ["10.0.0.0/16"]
  resource_group_name = var.rg
  location            = var.location
}

resource "azurerm_subnet" "subnet-1" {
  name                 = "subnet-1"
  resource_group_name  = var.rg
  virtual_network_name = azurerm_virtual_network.vnet-1.name
  address_prefixes     = ["10.0.0.0/24"]
}
#resource "azurerm_subnet" "subnet-2" {
#  name                 = "subnet-2"
#  resource_group_name  = var.rg
#  virtual_network_name = azurerm_virtual_network.vnet-1.name
#  address_prefixes     = ["10.0.1.0/24"]
#}
