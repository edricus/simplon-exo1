resource "azurerm_windows_virtual_machine" "vm" {
  count               = length(var.vm_win)
  name                = lookup(var.vm_win[count.index],"name")
  resource_group_name = var.rg
  location            = var.location
  size                = lookup(var.vm_win[count.index],"size")
  admin_username      = var.username
  admin_password      = "P@ssword2023"
  network_interface_ids = [
    azurerm_network_interface.nic[2].id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "StandardSSD_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
