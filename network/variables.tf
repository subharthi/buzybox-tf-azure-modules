#variable "owner_custom" {
#    description = "Short name of owner"
#}

#variable "purpose_custom" {
#    description = "Custom purpose"
#}

variable "location" {
  description = "Location where resource is to be created"
  
}

variable "name" {
  type = string
}
variable "vnet_name"{
  type = string
  description = "name of the vnet"
}

variable "address_prefixes" {
  type = list
  description = "VNET CIDR Range"
}

variable "subnet_delegation" {
  type = string
}

#variable "subnets" {
#  description = "A map to create multiple subnets"
#  type = map(object({
#    name = string
#    address_space = list(string)
#    subnet_delegation = string
#  })) 
#}
#
#variable "subnet" {
#  description = "one subnet"
#  type = map(object({
#    name = string
#    address_space = list(string)
#    subnet_delegation = string
#  }))
#}
#
#
#variable "nsg" {
#  description = "A map of NSGs"
#  type = map(object({
#    name = string
#  }))
#  
#}
#
variable "rg_name"{
  description = "resource group name"
  type = string  
}