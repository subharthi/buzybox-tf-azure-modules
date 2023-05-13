terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.15.0"
    }
  }
}

# Retrieve domain information
data "azuread_domains" "buzybox_domain" {
  only_initial = true
}

locals{
  users       = csvdecode(file("${path.module}/../../configuration/users.csv"))
  domain_name = data.azuread_domains.buzybox_domain.domains.0.domain_name
}

resource "random_pet" "suffix" {
  length = 2
}

resource "azuread_user" "users" {
  for_each = { for user in local.users : user.first_name => user }

  user_principal_name = format(
    "%s@%s",
    each.value.first_name,
   # substr(lower(each.value.first_name), 0 , 1),
   # lower(each.value.last_name),
   # random_pet.suffix.id,
    local.domain_name
  )
  password = format(
    "%s",
    each.value.password
  #  lower(each.value.last_name),
  #  substr(lower(each.value.first_name), 0 , 1),
  #  length(each.value.first_name)
  )
  # for the demo, we do not want to change the password 
  force_password_change = false

  display_name = "${each.value.first_name} ${each.value.last_name}"
  department   = each.value.department
  job_title    = each.value.job_title
}

## Create an application
#resource "azuread_application" "buzybox_application" {
#  display_name = "Buzybox-test"
#}
#
## Create a service principal
#resource "azuread_service_principal" "buzybox-service-principal" {
#  application_id = azuread_application.buzybox_application.application_id
#}
#