variable "name"{
  type = string
  description = "name of the vnet"
}

variable "address_space" {
  type = list
  description = "VNET CIDR Range"
}

variable "location" {
  description = "Location where resource is to be created"
  
}

variable "rg_name"{
  description = "resource group name"
  type = string  
}