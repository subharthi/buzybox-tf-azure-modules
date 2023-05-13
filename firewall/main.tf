#locals {
#  resource_group_name = format("rg-%s-%s", var.owner_custom, var.purpose_custom)
#}


resource "azurerm_public_ip" "public-ip" {
  name                = format("public-ip-%s-%s", var.owner_custom, var.purpose_custom)
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_firewall" "adb-firewall" {
  name                = format("firewall-%s-%s", var.owner_custom, var.purpose_custom)
  location            = var.location
  resource_group_name = var.resource_group_name

  ip_configuration {
    name                 = "adb_configuration"
    subnet_id            = var.fw_subnet_id
    public_ip_address_id = azurerm_public_ip.public-ip.id
  }
}

resource "azurerm_firewall_application_rule_collection" "adb_application_rules" {
  name                = "adb-control-plane-app-rules"
  azure_firewall_name = azurerm_firewall.adb-firewall.name
  resource_group_name = var.resource_group_name
  priority = 200
  action = "Allow" 

  rule {
    name = "artifact-log-blob-storage"
    source_addresses = ["10.10.1.0/26","10.10.1.64/26"]
    target_fqdns = ["dblogprodeastus2.blob.core.windows.net", "dblogprodwestus.blob.core.windows.net"]
     protocol {
      port = "443"
      type = "Https"
    }
  }

    rule {
    name = "artifact-blob-storage"
    source_addresses = ["10.10.1.0/26","10.10.1.64/26"]
    target_fqdns =["dbartifactsprodeastus.blob.core.windows.net", "arprodeastusa1.blob.core.windows.net", "arprodeastusa2.blob.core.windows.net", "arprodeastusa3.blob.core.windows.net", "arprodeastusa4.blob.core.windows.net", "arprodeastusa5.blob.core.windows.net", "arprodeastusa6.blob.core.windows.net"] 
     protocol {
      port = "443"
      type = "Https"
    }
  }
 # this information needs to be percolated down
  rule {
    name = "adb-root-dbfs"
    source_addresses = ["10.10.1.0/26","10.10.1.64/26"]
    target_fqdns = ["dbstorageeyfymddkmalau.blob.core.windows.net", "dbstorageeyfymddkmalau.dfs.core.windows.net"]
     protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "adb-relay-ssc-tunnel"
    source_addresses = ["10.10.1.0/26","10.10.1.64/26"]
    target_fqdns = ["tunnel.eastus2.azuredatabricks.net", "tunnel.eastusc3.azuredatabricks.net"]
     protocol {
      port = "443"
      type = "Https"
    }
  }

  rule {
    name = "adb-eventhub-endpoint"
    source_addresses = ["10.10.1.0/26","10.10.1.64/26"]
    target_fqdns = ["prod-eastusc2-observabilityeventhubs.servicebus.windows.net","prod-eastusc3-observabilityeventhubs.servicebus.windows.net","prod-westus-observabilityEventHubs.servicebus.windows.net"]
     protocol {
      port = "443"
      type = "Https"
    }
  }
 
  rule {
    name = "adb-metastore"
    source_addresses = ["10.10.1.0/26","10.10.1.64/26"]
    target_fqdns = ["consolidated-eastus-prod-metastore.mysql.database.azure.com", "consolidated-eastus-prod-metastore-addl-1.mysql.database.azure.com", "consolidated-eastus-prod-metastore-addl-2.mysql.database.azure.com", "consolidated-eastus-prod-metastore-addl-3.mysql.database.azure.com","consolidated-eastus-prod-metastore-addl-4.mysql.database.azure.com","consolidated-eastusc2-prod-metastore-0.mysql.database.azure.com", "consolidated-eastusc3-prod-metastore-0.mysql.database.azure.com", "consolidated-eastusc3-prod-metastore-1.mysql.database.azure.com", "consolidated-eastusc3-prod-metastore-2.mysql.database.azure.com", "consolidated-eastusc3-prod-metastore-3.mysql.database.azure.com"]
     protocol {
      port = "443"
      type = "Https"
    }
  }

}


resource "azurerm_firewall_network_rule_collection" "adb_network_rules" {
  name                = "adb-control-plane-network-rules"
  azure_firewall_name = azurerm_firewall.adb-firewall.name
  resource_group_name = var.resource_group_name
  priority            = 200
  action              = "Allow"

  rule {
      name = "adb-webapp"
      source_addresses = ["10.10.1.0/26","10.10.1.64/26"]
      destination_ports = ["443"]
      destination_addresses = ["40.70.58.221/32","20.42.4.209/32", "20.42.4.211/32"]
      protocols = ["Any"]
  }

  rule {
      name = "extended-infrastructure"
      source_addresses = ["10.10.1.0/26","10.10.1.64/26"]
      destination_ports = ["443"]
      destination_addresses = ["20.57.106.0/28"]
      protocols = ["Any"]
  }
}

resource "azurerm_route_table" "adb-route-table" {
  name                          = "adb-route-table"
  location                      = var.location
  resource_group_name           = var.resource_group_name

  route {
    name           = "to-firewall"
    address_prefix = "0.0.0.0/0"
    next_hop_type  = "VirtualAppliance"
    next_hop_in_ip_address = azurerm_firewall.adb-firewall.ip_configuration[0].private_ip_address
  }

#  route {
#      name = "to-scc-relay"
#      address_prefix = "13.75.164.240/28"
#      next_hop_type = "Internet"
#  }
}

resource "azurerm_subnet_route_table_association" "adb-pubic-rt-assocation" {
  subnet_id      = var.rt_public_subnet
  route_table_id = azurerm_route_table.adb-route-table.id
}

resource "azurerm_subnet_route_table_association" "adb-private-rt-assocation" {
  subnet_id      = var.rt_private_subnet
  route_table_id = azurerm_route_table.adb-route-table.id
}