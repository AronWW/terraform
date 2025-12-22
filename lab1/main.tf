terraform {
  required_providers {
    azuread = {
      source  = "hashicorp/azuread"
      version = "~> 2.53.0"
    }
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
  subscription_id = "74e02163-548f-4c13-a086-aa0f0a770e82"
  tenant_id       = "bf20b5c2-ca59-492b-aecd-d351e8c43340"
}

provider "azuread" {
  tenant_id = "bf20b5c2-ca59-492b-aecd-d351e8c43340"
}

data "azuread_client_config" "current" {}

locals {
  tenant_domain = "ayronzzz12gmail.onmicrosoft.com"
}

# Task 1: Створення користувачів
resource "azuread_user" "az104_user1" {
  user_principal_name   = "az104-01a-aaduser1@${local.tenant_domain}"
  display_name          = "az104-01a-aaduser1"
  password              = "P@ssw0rd1234!"
  force_password_change = false
  job_title             = "Cloud Administrator"
  department            = "IT"
  usage_location        = "US"
}

resource "azuread_user" "az104_user2" {
  user_principal_name   = "az104-01a-aaduser2@${local.tenant_domain}"
  display_name          = "az104-01a-aaduser2"
  password              = "P@ssw0rd1234!"
  force_password_change = false
  job_title             = "System Administrator"
  department            = "IT"
  usage_location        = "US"
}

# Task 1: Запрошення зовнішнього користувача
resource "azuread_invitation" "external_user" {
  user_display_name  = "Ivan External"
  user_email_address = "ivan877712@gmail.com"
  redirect_url       = "https://portal.azure.com"
}

# Task 2: Створення груп
resource "azuread_group" "cloud_admins" {
  display_name     = "IT Cloud Administrators"
  description      = "Cloud Administrators group for Lab 01"
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  members = [
    azuread_user.az104_user1.object_id
  ]
}

resource "azuread_group" "system_admins" {
  display_name     = "IT System Administrators"
  description      = "System Administrators group for Lab 01"
  security_enabled = true
  owners           = [data.azuread_client_config.current.object_id]
  members = [
    azuread_user.az104_user2.object_id,
    azuread_invitation.external_user.user_id
  ]
}

# Task 4: Призначення ролі User Administrator
resource "azuread_directory_role" "user_administrator" {
  display_name = "User Administrator"
}

resource "azuread_directory_role_assignment" "user_admin_assignment" {
  role_id             = azuread_directory_role.user_administrator.template_id
  principal_object_id = azuread_user.az104_user1.object_id
}

# Outputs
output "user1_upn" {
  value = azuread_user.az104_user1.user_principal_name
}

output "user2_upn" {
  value = azuread_user.az104_user2.user_principal_name
}

output "external_user_email" {
  value = azuread_invitation.external_user.user_email_address
}

output "external_user_redeem_url" {
  value = azuread_invitation.external_user.redeem_url
}

output "cloud_admins_group" {
  value = azuread_group.cloud_admins.display_name
}

output "system_admins_group" {
  value = azuread_group.system_admins.display_name
}
