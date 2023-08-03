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

variable "brief_tag"{
  type = string
  description = "Tag correspondant au brief"
}

variable "nb_srv"{
  type = number
  description = "Nb de serveurs dans notre sous-réseau de couche web"
}

variable "img_name" {
  type = string
  ddescription = "nom de l'image packer pour les serveurs web"  
}

variable "img_rg" {
  type = string
  description = "Resource group où trouver l'image packer"
}