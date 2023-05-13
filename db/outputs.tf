output "db_username" {
    value = azurerm_key_vault_secret.db_un.name
}

output "db_password" {
    value = azurerm_key_vault_secret.db_pw.name
}

#output "db_username_id" {
#    value =  azurerm_key_vault_secret.db_un.id 
#}

#output "db_password_id" {
#    value =  azurerm_key_vault_secret.db_pw.id 
#}