output "buzybox_users" {
    value = {for users in azuread_user.users: users.display_name => users}
  
}