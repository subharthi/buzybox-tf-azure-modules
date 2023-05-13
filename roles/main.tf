# allocating databricks roles to buzybox_users 
terraform {
    required_providers {
      databricks = {
        source  = "databricks/databricks"
        version = "1.3.0"
    }
  }
}

# create databricks users
# will add more granualar policies for a user later.
# for now we have 2 roles for databricks:
# 1. Databricks admin and workspace admin - the script  
# 3. Databricks workspace user

resource "databricks_user" "databricks_users" {
  for_each = { for k,v in var.buzybox_users: k => v}
  user_name            = each.value.user_principal_name
  display_name         = each.key
  allow_cluster_create = true
}


