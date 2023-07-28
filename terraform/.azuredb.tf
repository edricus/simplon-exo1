resource "azurerm_mariadb_server" "db_server" {
  name                = "db${random_string.db_name.result}"
  location            = var.location
  resource_group_name = var.rg

  sku_name = "GP_Gen5_2"

  storage_mb                   = 32768
  backup_retention_days        = 7
  geo_redundant_backup_enabled = false

  administrator_login          = var.username
  administrator_login_password = random_password.db_password.result
  version                      = "10.2"
  ssl_enforcement_enabled      = false
  ssl_minimal_tls_version_enforced = "TLSEnforcementDisabled"
}

resource "azurerm_mariadb_database" "db" {
  name                = "nextcloud"
  resource_group_name = var.rg
  server_name         = azurerm_mariadb_server.db_server.name
  charset             = "utf8mb4"
  collation           = "utf8mb4_unicode_520_ci"
}

resource "azurerm_mariadb_firewall_rule" "db_rule" {
  name                = "allow-all"
  resource_group_name = var.rg
  server_name         = azurerm_mariadb_server.db_server.name
  start_ip_address    = "0.0.0.0"
  end_ip_address      = "255.255.255.255"
}
