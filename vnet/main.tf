resource "azurerm_virtual_network" "vnet" {
  #name                = format("%s-%s-vnet", var.owner_custom, var.purpose_custom)
  name                = var.name 
  location            = var.location
  resource_group_name = var.rg_name #local.resource_group_name
  address_space       = var.address_space

}
