 #output "user_principal_names" {
 #   value = {for k, v in azuread_user.users: k=>v.user_principal_name}
  
#}
output "adb_id" {
    value = azurerm_databricks_workspace.adb.id
  
}