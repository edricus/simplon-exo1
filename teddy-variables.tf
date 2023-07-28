variable "rg" {
  type = string
}
variable "location" {
  type = string
}
variable "username" {
  type = string
  description = "Nom d'utilisateur de la VM"
}
variable "vm_size" {
  type = string
  description = "Taille de la VM Azure (exemple: \"Standard_B1ls\", \"Standard_B2ms\")"
}
variable "ssh_key" {
  type = string
  description = "Clé SSH à donner à la VM"
}
