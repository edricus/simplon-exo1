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

# Je récupère une image packer d'un serveur nginx lancé, avec une page personnalisée
data "azurerm_image" "img" {
    name = var.img_name
    resource_group_name = var.img_rg
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

# On crée un lb public
resource "azurerm_public_ip" "publiclb-ip" {
  name                = "publiclb-ip"
  resource_group_name = var.rg
  location            = var.location
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_lb" "publiclb" {
  name                = "publiclb"
  resource_group_name = var.rg
  location            = var.location
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "publiclb-ip-association"
    public_ip_address_id = azurerm_public_ip.publiclb-ip.id
  }
}

resource "azurerm_lb_backend_address_pool" "publiclb-backend" {
loadbalancer_id = azurerm_lb.publiclb.id
name            = "publiclb-backend"
}
resource "azurerm_lb_rule" "publiclbrule" {
  loadbalancer_id                = azurerm_lb.publiclb.id
  name                           = "PubLBRule"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "publiclb-ip-association"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.publiclb-backend.id,]
}
resource "azurerm_lb_probe" "probe" {
  loadbalancer_id = azurerm_lb.publiclb.id
  name            = "tcp-probe"
  protocol        = "Tcp" 
  port            = 80
}

#On crée les serveurs web
#On crée un NSG dont les règles nous permettrons d'accéder à notre VM en SSH et de visiter le site web associé à son IP
resource "azurerm_network_security_group" "nsg" {
  name                = "Servers-nsg"
  location            = var.location
  resource_group_name = var.rg

  security_rule {
    name                       = "AllowHTTP"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Brief = var.brief_tag
    Owner = "Jess"
  }
}

#On crée les NICs des serveurs web
resource "azurerm_network_interface" "nic_server" {
  count = var.nb_srv
  name                = "Server${count.index}-nic"
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "server-config"
    subnet_id                     = azurerm_subnet.subnet-2.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    Brief = var.brief_tag
    Owner = "Jess"
  }
}
#On associe les NICs au NSG
resource "azurerm_network_interface_security_group_association" "nic_server" {
  count = var.nb_srv
  network_interface_id      = element(azurerm_network_interface.nic_server.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.nsg.id
}

#On associe ces NICs au backend address pool du lb public
resource "azurerm_network_interface_backend_address_pool_association" "nic_lb_assoc" {
  count = var.nb_srv
  network_interface_id    = element(azurerm_network_interface.nic_server.*.id, count.index)
  ip_configuration_name   = "server-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.publiclb-backend.id
}

#On crée les serveurs web
resource "azurerm_linux_virtual_machine" "WebServers" {
  count               = var.nb_srv
  name                = "Server${count.index}"
  resource_group_name = var.rg
  location            = var.location
  size                =var.vm_size
  admin_username      = "adminServer${count.index}"
  admin_ssh_key {
    username = "adminServer${count.index}"
    public_key = file("${var.ssh_key}.pub")
  }
  network_interface_ids = [element(azurerm_network_interface.nic_server.*.id, count.index),]
  os_disk {
    name = "Server${count.index}-OSdisk"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_id     = data.azurerm_image.img.id
}

# On crée le lb interne
resource "azurerm_lb" "lb_interne" {
  name                = "lb_interne"
  location            = var.location
  resource_group_name = var.rg
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "lb_interne_frontend"
    subnet_id = azurerm_subnet.subnet-3.id
  }

  tags = {
    Brief = var.brief_tag
    Owner = "Jess"
  }
}

resource "azurerm_lb_probe" "lb_interne" {
  loadbalancer_id = azurerm_lb.lb_interne.id
  name            = "tcp-probe"
  protocol        = "Tcp" 
  port            = 443
}

resource "azurerm_lb_backend_address_pool" "lb_interne_backend" {
  loadbalancer_id = azurerm_lb.lb_interne.id
  name            = "BackEndAddressPool"
}


resource "azurerm_lb_rule" "lb_internerule" {
  loadbalancer_id                = azurerm_lb.lb_interne.id
  name                           = "LBinterneRule"
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "lb_interne_frontend"
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_interne_backend.id]
}

# On crée les VMs des Base de donnée de la couche métier
resource "azurerm_network_security_group" "db-nsg" {
  name                = "db-nsg"
  location            = var.location
  resource_group_name = var.rg

  security_rule {
    name                       = "AllowHTTPS"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name                       = "AllowSSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    Brief = var.brief_tag
    Owner = "Jess"
  }
}
#On crée les NICs des serveurs de la couche métier
resource "azurerm_network_interface" "nic_db" {
  count = var.nb_srv
  name                = "db${count.index}-nic"
  location            = var.location
  resource_group_name = var.rg

  ip_configuration {
    name                          = "db-config"
    subnet_id                     = azurerm_subnet.subnet-4.id
    private_ip_address_allocation = "Dynamic"
  }
  tags = {
    Brief = var.brief_tag
    Owner = "Jess"
  }
}

#On associe les NICs au NSG
resource "azurerm_network_interface_security_group_association" "nic_db" {
  count                     = var.nb_srv
  network_interface_id      = element(azurerm_network_interface.nic_db.*.id, count.index)
  network_security_group_id = azurerm_network_security_group.db-nsg.id
}

#On associe ces NICs au backend address pool du lb privé
resource "azurerm_network_interface_backend_address_pool_association" "nic_db" {
  count = var.nb_srv
  network_interface_id    = element(azurerm_network_interface.nic_db.*.id, count.index)
  ip_configuration_name   = "db-config"
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_interne_backend.id
}

#On crée les serveurs de la couche métier
resource "azurerm_linux_virtual_machine" "DBServers" {
  count               = var.nb_srv
  name                = "db${count.index}"
  resource_group_name = var.rg
  location            = var.location
  size                =var.vm_size
  admin_username      = "adminDB${count.index}"
  admin_ssh_key {
    username = "adminDB${count.index}"
    public_key = file("${var.ssh_key}.pub")
  }
  network_interface_ids = [element(azurerm_network_interface.nic_db.*.id, count.index),]
  os_disk {
    name = "db${count.index}-OSdisk"
    caching = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_id     = data.azurerm_image.img.id
}