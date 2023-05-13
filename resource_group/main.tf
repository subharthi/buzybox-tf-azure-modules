resource "azurerm_resource_group" "rg" {
  #provider = var.provider_name
  #name     = format("rg-%s-%s", var.owner_custom, var.purpose_custom)
  name = var.rg_name
  location = var.location

  tags = {
    Org = var.org
    Name = var.rg_name
   # Purpose = var.purpose
  }
}