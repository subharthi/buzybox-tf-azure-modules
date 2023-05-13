#data "azurerm_billing_enrollment_account_scope" "this" {
#  billing_account_name    = var.billing_account_name
#  enrollment_account_name = var.enrollment_account_name
#}

#resource "azurerm_subscription" "this" {
#  subscription_name = var.subscription_name 
#  billing_scope_id  = data.azurerm_billing_enrollment_account_scope.this.id
#}

#terraform {
#  required_providers {
#     azurerm = {
#      source  = "hashicorp/azurerm"
#      version = "3.49.0"
#    }
#  }
#}
#
data "azurerm_billing_mca_account_scope" "this" {
  billing_account_name = var.billing_account_name 
  billing_profile_name = var.billing_profile_name
  invoice_section_name = var.invoice_section_name
}

resource "azurerm_subscription" "this" {
  subscription_name = var.subscription_name 
  billing_scope_id  = data.azurerm_billing_mca_account_scope.this.id
}