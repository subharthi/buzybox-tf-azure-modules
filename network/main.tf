#locals {
#  resource_group_name = format("rg-%s-%s", var.owner_custom, var.purpose_custom)
#}

locals {
  subnet_types = tomap({
    for k, s in var.subnets : k => split("_", s.name)[0]
  })
  nsg_types = tomap({
    for k, s in var.nsg : split("_", s.name)[0] => k
  })
}

locals {
  subnet_nsgs = {
    for k, ty in local.subnet_types :
    k => try(local.nsg_types[ty], null)
  }
}

locals{
  sg_allow_ssh = {
          name                       = "test123"
          priority                   = 100
          direction                  = "Inbound"
          access                     = "Allow"
          protocol                   = "Tcp"
          source_port_range          = "*"
          destination_port_range     = "22"
          source_address_prefix      = "*"
          destination_address_prefix = "*"
  }
}

resource "azurerm_subnet" "subnets" {
  name                 = var.name
  address_prefixes     = var.address_prefixes
  resource_group_name  = var.rg_name #local.resource_group_name
  virtual_network_name = var.vnet_name 

  dynamic "delegation" {
    for_each = each.value.subnet_delegation == "true" ? [1] : []
    content {
      name = "adb_delegation"
      service_delegation {
        name = "Microsoft.Databricks/workspaces"
        actions = [
          "Microsoft.Network/virtualNetworks/subnets/join/action",
          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
        ]
      }
    }
  }
}

#resource "azurerm_subnet" "subnets" {
#  for_each             = var.subnets
#  name                 = each.value["name"]
#  address_prefixes     = each.value["address_space"]
#  resource_group_name  = var.rg_name #local.resource_group_name
#  virtual_network_name = azurerm_virtual_network.vnet.name
#
#  dynamic "delegation" {
#    for_each = each.value.subnet_delegation == "true" ? [1] : []
#    content {
#      name = "adb_delegation"
#      service_delegation {
#        name = "Microsoft.Databricks/workspaces"
#        actions = [
#          "Microsoft.Network/virtualNetworks/subnets/join/action",
#          "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
#          "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action",
#        ]
#      }
#    }
#  }
#}
#
#resource "azurerm_network_security_group" "nsg-ssh" {
#  for_each            = var.nsg
#  name                = each.value["name"]
#  location            = var.location
#  resource_group_name = var.rg_name #local.resource_group_name
#  security_rule {
#          name                       = "test123"
#          priority                   = 100
#          direction                  = "Inbound"
#          access                     = "Allow"
#          protocol                   = "Tcp"
#          source_port_range          = "*"
#          destination_port_range     = "22"
#          source_address_prefix      = "*"
#          destination_address_prefix = "*"
#        }
#}
#
#
#resource "azurerm_subnet_network_security_group_association" "nsg_association" {
#  for_each = {
#    for subnet_key, nsg_key in local.subnet_nsgs : subnet_key => {
#      subnet_id = azurerm_subnet.subnets[subnet_key].id
#      nsg_id    = azurerm_network_security_group.nsg[nsg_key].id
#    }
#    if nsg_key != null
#  }
#
#  subnet_id                 = each.value.subnet_id
#  network_security_group_id = each.value.nsg_id
#}
#