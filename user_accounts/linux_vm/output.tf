
output "username_keys" {
   # value = tomap({
   #     for k, s in azurerm_subnet.subnets: k => s.id
   # })

   value = [
    for index,key in tls_private_key.linux_vm_user_key_pair :
   {
     username =  var.user_list[index].username
     public_key =  key.public_key_openssh
     private_key = key.private_key_openssh
     }]
}

#output "user-list" { 
#    value = var.username 
#}

#output "public_key"{
#     value = tls_private_key.linux_vm_user_key_pair.public_key_pem
#}

#output "private_key"{
#     value = tls_private_key.linux_vm_user_key_pair.public_key_pem
#     sensitive = true
#}
