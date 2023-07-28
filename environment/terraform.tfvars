vm_lin = [
  {
      name = "vm-linux-apache"
      size = "Standard_B2s"
  },
  {
      name = "vm-linux-rproxy"
      size = "Standard_B2s"
  }
]

nic = [
  { 
      name = "nic-1" 
  },
  { 
      name = "nic-2"
  },
  {
      name = "nic-3"
  }
]

ip = [
  { 
      name = "ip-1" 
      sku  = "Basic"
  },
  { 
      name = "ip-2" 
      sku  = "Basic"
  },
  { 
      name = "ip-3" 
      sku  = "Basic"
  }
#  {
#      name = "ip-appgw"
#      sku  = "Standard"
#  },
]
dbs = [
  {
      name = "nextcloud"
  }
]
vm_win = [
  { 
      name = "vm-winsrv-1"
      size = "Standard_B2s"
  }
#  { 
#      name = "vm-windows-2" 
#      size = "Standard_B2s"
#  }
]
