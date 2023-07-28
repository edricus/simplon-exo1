locals {
  backend_address_pool_name      = "${azurerm_virtual_network.vnet-1.name}-beap"
  frontend_port_name             = "${azurerm_virtual_network.vnet-1.name}-feport"
  frontend_ip_configuration_name = "${azurerm_virtual_network.vnet-1.name}-feip"
  http_setting_name              = "${azurerm_virtual_network.vnet-1.name}-be-htst"
  listener_name                  = "${azurerm_virtual_network.vnet-1.name}-httplstn"
  request_routing_rule_name      = "${azurerm_virtual_network.vnet-1.name}-rqrt"
  redirect_configuration_name    = "${azurerm_virtual_network.vnet-1.name}-rdrcfg"
}

resource "azurerm_application_gateway" "appgw" {
  name                = "Teddy-appgw"
  resource_group_name = var.rg
  location            = var.location

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 1
  }
  waf_configuration {
    enabled   = "true"
    firewall_mode = "Prevention"
    rule_set_version = "3.2"
  }
  gateway_ip_configuration {
    name      = "Teddy_APPGW_subnet"
    subnet_id = azurerm_subnet.subnet-2.id
  }

  frontend_port {
    name = local.frontend_port_name
    port = 80
  }

  frontend_ip_configuration {
    name                 = local.frontend_ip_configuration_name
    public_ip_address_id = azurerm_public_ip.public-ip[2].id
  }

  backend_address_pool {
    name = local.backend_address_pool_name
  }

  backend_http_settings {
    name                  = local.http_setting_name
    cookie_based_affinity = "Disabled"
    port                  = 80
    protocol              = "Http"
    request_timeout       = 60
  }

  http_listener {
    name                           = local.listener_name
    frontend_ip_configuration_name = local.frontend_ip_configuration_name
    frontend_port_name             = local.frontend_port_name
    protocol                       = "Http"
  }

  request_routing_rule {
    name                       = local.request_routing_rule_name
    rule_type                  = "Basic"
    priority                   = "100"
    http_listener_name         = local.listener_name
    backend_address_pool_name  = local.backend_address_pool_name
    backend_http_settings_name = local.http_setting_name
  }
}
resource "azurerm_network_interface_application_gateway_backend_address_pool_association" "beap-association" {
  count                   = length(var.nic)
  network_interface_id    = azurerm_network_interface.nic[count.index].id
  ip_configuration_name   = "nic-ip"
  backend_address_pool_id = tolist(azurerm_application_gateway.appgw.backend_address_pool).0.id
}

