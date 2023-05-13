module "os" {
  source       = "../../os"
  vm_os_simple = "${var.vm_os_simple}"
}

#resource "azurerm_resource_group" "vm" {
#  name     = "${var.resource_group_name}"
#  location = "${var.location}"
#  tags     = "${var.tags}"
#}
#

locals{
  custom_data = "<<EOF EOF"
}
resource "random_id" "vm-sa" {
  keepers = {
    vm_hostname = "${var.vm_hostname}"
  }

  byte_length = 6
}

module "vm_user_accounts"{
  source = "../../user_accounts/linux_vm"
  user_list = var.user_list
  hostname = var.vm_hostname
}

data "template_cloudinit_config" "addusers" {
 gzip          = true
 base64_encode = true
 part {
   filename     = "cloud-init.cfg"
   content_type = "text/cloud-config"
   content = templatefile("${path.module}/templates/useradd.yaml", {
       user_accounts = module.vm_user_accounts.username_keys
   })
 }
}


resource "azurerm_storage_account" "vm-sa" {
  count                    = "${var.boot_diagnostics == "true" ? 1 : 0}"
  name                     = "bootdiag${lower(random_id.vm-sa.hex)}"
  resource_group_name      = "${var.resource_group_name}"
  location                 = "${var.location}"
  account_tier             = "${element(split("_", var.boot_diagnostics_sa_type),0)}"
  account_replication_type = "${element(split("_", var.boot_diagnostics_sa_type),1)}"
  tags                     = "${var.tags}"
}

resource "azurerm_linux_virtual_machine" "vm-linux" {
  count                         = var.vm_count #"${!contains(concat(["${var.vm_os_simple}"],["${var.vm_os_offer}"]), "WindowsServer") && var.is_windows_image != "true" && var.data_disk == "false" ? var.nb_instances : 0}"
  name                          = "${var.vm_hostname}_${count.index}"
  location                      = "${var.location}"
  resource_group_name           = "${var.resource_group_name}"
  availability_set_id           = "${azurerm_availability_set.vm.id}"
  size                          = "${var.vm_size}"
  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
  #delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"

  source_image_reference {
    #id        = "${var.vm_os_id}"
    publisher = var.vm_os_publisher #"Canonical" #"${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
    offer     = var.vm_os_offer #"UbuntuServer" #"${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
    sku       = var.vm_os_sku #"16.04-LTS"#"${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
    version   = var.vm_os_version #"latest" #"${var.vm_os_id == "" ? var.vm_os_version : ""}"
  }

  os_disk {
    name              = "osdisk-${var.vm_hostname}_${count.index}"
    #create_option     = "FromImage"
    caching           = "ReadWrite"
    storage_account_type = "${var.storage_account_type}"
  }
    computer_name  = "${var.vm_hostname}${count.index}"
    admin_username = "ubuntu" #"${var.admin_username}"
    admin_password = "Redbox1!" #"${var.admin_password}"
  

  #os_profile_linux_config {
    disable_password_authentication = false

    admin_ssh_key {
      username = var.admin_username
      public_key = var.admin_ssh_public_key # file("/Users/subharthipaul/.ssh/workload_vm.pub") #var.admin_ssh_public_key #file("~/.ssh/multi-proxy.pub") #"${var.admin_ssh_public_key}" #file("${var.admin_ssh_public_key}")
      #path     = "/home/${var.admin_username}/.ssh/authorized_keys"
      #key_data = "${file("${var.ssh_key}")}"
    }
#  }
#  provisioner "file" {
#    source      = "${var.file_source}" #"../../proxy_nodes/mitm"
#    destination =  "${var.file_destination}" #"/home/ubuntu"
#    
#    connection {
#      type        = "ssh"
#      user        = "${var.admin_username}"
#      private_key =  var.admin_ssh_private_key #file("~/.ssh/multi-proxy")   #"${var.admin_ssh_private_key}" #file("${var.admin_ssh_private_key}")  #file("~/aws/keys/gpu-user.pem")
#      #host        = "${element(azurerm_public_ip.vm.*.ip_address, count.index)}"     #"${element(self.network_interface_ids, count.index).ip_configuration[0].public_ip_address_id.ip_address}"    #{self.network_interface_ids.ip_configuration[0].public_ip_address_id.ip_address}"
#      host        = join(".", ["${element(azurerm_public_ip.vm.*.domain_name_label,count.index)}", "${element(azurerm_public_ip.vm.*.location,count.index)}","cloudapp.azure.com"])
#     # host        = join(".", ["${element(azurerm_public_ip.vm.*.domain_name_label,0)}", "${element(azurerm_public_ip.vm.*.location,0)}","cloudapp.azure.com"])
#      #["${element(var.public_ip_dns, count.index)}","${var.location}"], "cloudapp.azure.com" )    #"${element(data.azurerm_public_ip.data_public_ip.ip_address, count.index)}"     #"${element(self.network_interface_ids, count.index).ip_configuration[0].public_ip_address_id.ip_address}"    #{self.network_interface_ids.ip_configuration[0].public_ip_address_id.ip_address}"
#    }
#  }
#  
 custom_data = data.template_cloudinit_config.addusers.rendered  #var.user_data_path != "" ? filebase64(file("${var.user_data_path}")) : base64encode(local.custom_data) #//file("${path.module}/${var.user_data_path}") #("${path.module}/../proxy_nodes/mitm/provision_mitm_node_tf.sh")
  
  

  tags = "${var.tags}"

  boot_diagnostics {
    #enabled     = "${var.boot_diagnostics}"
    storage_account_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : "" }"
  }

#depends_on = [azurerm_network_interface.vm]
}

#resource "azurerm_linux_virtual_machine" "vm-linux-with-datadisk" {
#  count                         = "${!contains(concat("${var.vm_os_simple}","${var.vm_os_offer}"), "WindowsServer")  && var.is_windows_image != "true"  && var.data_disk == "true" ? var.nb_instances : 0}"
#  name                          = "${var.vm_hostname}${count.index}"
#  location                      = "${var.location}"
#  resource_group_name           = "${azurerm_resource_group.vm.name}"
#  availability_set_id           = "${azurerm_availability_set.vm.id}"
#  vm_size                       = "${var.vm_size}"
#  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
#  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"
#
#  storage_image_reference {
#    id        = "${var.vm_os_id}"
#    publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
#    offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
#    sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
#    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
#  }
#
#  storage_os_disk {
#    name              = "osdisk-${var.vm_hostname}-${count.index}"
#    create_option     = "FromImage"
#    caching           = "ReadWrite"
#    managed_disk_type = "${var.storage_account_type}"
#  }
#
#  storage_data_disk {
#    name              = "datadisk-${var.vm_hostname}-${count.index}"
#    create_option     = "Empty"
#    lun               = 0
#    disk_size_gb      = "${var.data_disk_size_gb}"
#    managed_disk_type = "${var.data_sa_type}"
#  }
#
#  os_profile {
#    computer_name  = "${var.vm_hostname}${count.index}"
#    admin_username = "${var.admin_username}"
#    admin_password = "${var.admin_password}"
#  }
#
# # os_profile_linux_config {
#    disable_password_authentication = true
#
#    ssh_keys {
#      path     = "/home/${var.admin_username}/.ssh/authorized_keys"
#      key_data = "${file("${var.ssh_key}")}"
#    }
##  }
#
#  tags = "${var.tags}"
#
#  boot_diagnostics {
#    enabled     = "${var.boot_diagnostics}"
#    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : "" }"
#  }
#}
#
#resource "azurerm_windows_virtual_machine" "vm-windows" {
#  count                         = "${(((var.vm_os_id != "" && var.is_windows_image == "true") || contains(concat("${var.vm_os_simple}","${var.vm_os_offer}"), "WindowsServer")) && var.data_disk == "false") ? var.nb_instances : 0}"
#  name                          = "${var.vm_hostname}${count.index}"
#  location                      = "${var.location}"
#  resource_group_name           = "${azurerm_resource_group.vm.name}"
#  availability_set_id           = "${azurerm_availability_set.vm.id}"
#  vm_size                       = "${var.vm_size}"
#  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
#  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"
#
#  storage_image_reference {
#    id        = "${var.vm_os_id}"
#    publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
#    offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
#    sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
#    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
#  }
#
#  storage_os_disk {
#    name              = "osdisk-${var.vm_hostname}-${count.index}"
#    create_option     = "FromImage"
#    caching           = "ReadWrite"
#    managed_disk_type = "${var.storage_account_type}"
#  }
#
#  os_profile {
#    computer_name  = "${var.vm_hostname}${count.index}"
#    admin_username = "${var.admin_username}"
#    admin_password = "${var.admin_password}"
#  }
#
#  tags = "${var.tags}"
#
#  os_profile_windows_config {}
#
#  boot_diagnostics {
#    enabled     = "${var.boot_diagnostics}"
#    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : "" }"
#  }
#}
#
#resource "azurerm_windows_virtual_machine" "vm-windows-with-datadisk" {
#  count                         = "${((var.vm_os_id != "" && var.is_windows_image == "true") || contains(concat("${var.vm_os_simple}","${var.vm_os_offer}"), "WindowsServer")) && var.data_disk == "true" ? var.nb_instances : 0}"
#  name                          = "${var.vm_hostname}${count.index}"
#  location                      = "${var.location}"
#  resource_group_name           = "${azurerm_resource_group.vm.name}"
#  availability_set_id           = "${azurerm_availability_set.vm.id}"
#  vm_size                       = "${var.vm_size}"
#  network_interface_ids         = ["${element(azurerm_network_interface.vm.*.id, count.index)}"]
#  delete_os_disk_on_termination = "${var.delete_os_disk_on_termination}"
#
#  storage_image_reference {
#    id        = "${var.vm_os_id}"
#    publisher = "${var.vm_os_id == "" ? coalesce(var.vm_os_publisher, module.os.calculated_value_os_publisher) : ""}"
#    offer     = "${var.vm_os_id == "" ? coalesce(var.vm_os_offer, module.os.calculated_value_os_offer) : ""}"
#    sku       = "${var.vm_os_id == "" ? coalesce(var.vm_os_sku, module.os.calculated_value_os_sku) : ""}"
#    version   = "${var.vm_os_id == "" ? var.vm_os_version : ""}"
#  }
#
#  storage_os_disk {
#    name              = "osdisk-${var.vm_hostname}-${count.index}"
#    create_option     = "FromImage"
#    caching           = "ReadWrite"
#    managed_disk_type = "${var.storage_account_type}"
#  }
#
#  storage_data_disk {
#    name              = "datadisk-${var.vm_hostname}-${count.index}"
#    create_option     = "Empty"
#    lun               = 0
#    disk_size_gb      = "${var.data_disk_size_gb}"
#    managed_disk_type = "${var.data_sa_type}"
#  }
#
#  os_profile {
#    computer_name  = "${var.vm_hostname}${count.index}"
#    admin_username = "${var.admin_username}"
#    admin_password = "${var.admin_password}"
#  }
#
#  tags = "${var.tags}"
#
#  os_profile_windows_config {}
#
#  boot_diagnostics {
#    enabled     = "${var.boot_diagnostics}"
#    storage_uri = "${var.boot_diagnostics == "true" ? join(",", azurerm_storage_account.vm-sa.*.primary_blob_endpoint) : "" }"
#  }
#}
#
resource "azurerm_availability_set" "vm" {
  name                         = "${var.vm_hostname}-avset"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  platform_fault_domain_count  = 2
  platform_update_domain_count = 2
  managed                      = true
}

resource "azurerm_public_ip" "vm" {
  count                        = "${var.vm_count}"
  name                         = "${var.vm_hostname}-${count.index}-publicIP"
  location                     = "${var.location}"
  resource_group_name          = "${var.resource_group_name}"
  allocation_method            = "${var.allocation_method}"
  domain_name_label            = "${var.public_ip_dns_prefix}-${count.index}"
}

#dynamic ip allocations causes problems when the allocated ip is referenced in a host block

#data "azurerm_public_ip" "data_public_ip"{
#  count = "${var.nb_instances}"
#  name = "${element(azurerm_public_ip.vm.name, count.index)}"
#  resource_group_name = "${var.resource_group_name}"
#  depends_on = [azurerm_network_interface.vm]
#}
#


resource "azurerm_network_interface" "vm" {
  count                     = "${var.vm_count}"
  name                      = "nic-${var.vm_hostname}-${count.index}"
  location                  = "${var.location}"
  resource_group_name       = "${var.resource_group_name}"
  #network_security_group_id = "${var.nsg_id}"

  ip_configuration {
    name                          = "ipconfig${count.index}"
    subnet_id                     = "${var.vnet_subnet_id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${length(azurerm_public_ip.vm.*.id) > 0 ? element(concat(azurerm_public_ip.vm.*.id, tolist([""])), count.index) : ""}"
  }
}