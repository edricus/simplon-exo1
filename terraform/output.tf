resource "random_string" "storage_account_name" {
  length  = 5
  special = false
  upper   = false
}
#resource "random_string" "db_name" {
#  length  = 5
#  special = false
#  upper   = false
#}
#resource "random_password" "db_password" {
#  length  = 15
#  special = true
#  upper   = true
#}
#output db_password {
#  value     = random_password.db_password.result
#  sensitive = true
#}
#output db_name {
#  value     = random_string.db_name.result
#}
