variable "owner_custom" {
  description = "Short name of owner"
}

variable "purpose_custom" {
  description = "Custom purpose"
}
variable "location" {
  description = "Location in which resource needs to be spinned up"
}

variable "vnet_id" {
  description = "VNET ID to be passed for ADB"

}

variable "public_subnet_network_security_group_association_id" {
}

variable "private_subnet_network_security_group_association_id" {
}

variable "key_vault_id" {
  
}

variable "key_vault_uri" {
  
}

variable "resource_group_name" {
  description = "resource group name"
}

variable "db_username" {
  description = "username for the db"
}

variable "db_password"{
  description = "db password"
}

#variable "db_username_secret_resource_id"{
#  description = "db username secret resource id"
#}

#variable "db_password_secret_resource_id"{
#  description = "db password resource id"
#}