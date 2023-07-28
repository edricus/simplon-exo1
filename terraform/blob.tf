resource "azurerm_storage_account" "storage-account" {
  name                     = "teddy${random_string.storage_account_name.result}"
  resource_group_name      = var.rg
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
}
resource "azurerm_storage_share" "share" {
  name                 = "nextcloud"
  storage_account_name = azurerm_storage_account.storage-account.name
  quota                = 4
}

