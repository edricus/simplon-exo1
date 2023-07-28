resource "azurerm_public_ip" "public-ip" {
  count               = length(var.ip)
  name                = lookup(var.ip[count.index],"name")
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = "Static"
  sku                 = lookup(var.ip[count.index],"sku")
}

resource "azurerm_network_interface" "nic" {
  count               = length(var.nic)
  name                = lookup(var.nic[count.index],"name")
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "nic-ip"
    subnet_id                     = azurerm_subnet.subnet-1.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.public-ip[count.index].id
  }
}

resource "azurerm_linux_virtual_machine" "vm" {
  count               = length(var.vm_lin)
  name                = lookup(var.vm_lin[count.index],"name")
  resource_group_name = var.rg
  location            = var.location
  size                = lookup(var.vm_lin[count.index],"size")
  admin_username      = var.username
  admin_password      = "P@ssword2023" # WARNING
  network_interface_ids = [
    azurerm_network_interface.nic[count.index].id,
  ]

  admin_ssh_key {
    username   = var.username
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11-backports-gen2"
    version   = "latest"
  }
}

resource "azurerm_virtual_machine_extension" "docker_install" {
#  count                = length(var.vm_lin)
  name                 = "docker_install"
#  virtual_machine_id   = azurerm_linux_virtual_machine.vm[count.index].id
  virtual_machine_id   = azurerm_linux_virtual_machine.vm[0].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "script" : "${base64encode(file("${path.module}/scripts/docker_install.sh"))}"
 }
SETTINGS
}

resource "azurerm_virtual_machine_extension" "npm_install" {
#  count                = length(var.vm_lin)
  name                 = "npm_install"
#  virtual_machine_id   = azurerm_linux_virtual_machine.vm[count.index].id
  virtual_machine_id   = azurerm_linux_virtual_machine.vm[1].id
  publisher            = "Microsoft.Azure.Extensions"
  type                 = "CustomScript"
  type_handler_version = "2.0"

  settings = <<SETTINGS
 {
  "script" : "${base64encode(file("${path.module}/scripts/npm_install.sh"))}"
 }
SETTINGS
}
