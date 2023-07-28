variable "rg" {
  default = "RG_Teddy"
}
variable "storage_account" {
  default = "XueVLy7YHDr2ysz"
}
variable "location" {
  default = "NorthEurope"
}
variable "username" {
  default = "adminuser"
}
variable "nic" {
  type = list(map(string))
  default = []
}
variable "vm_win" {
  type = list(map(string))
  default = []
}
variable "vm_lin" {
    type = list(map(string))
    default = []
}
variable "ip" {
  type = list(map(string))
  default = []
}
variable "subnet" {
  type = list(map(string))
  default = []
}
variable "dbs" {
  type = list(map(string))
  default = []
}
