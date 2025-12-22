terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0.2"
    }
  }


  required_version = ">= 1.1.0"
}


provider "azurerm" {
  features {}
}


resource "azurerm_resource_group" "az104_rg2" {
  name     = "az104-rg2"
  location = "East US"


  tags = {
    "Cost Center" = "000"
  }
}


data "azurerm_policy_definition" "require_tag_value" {
  display_name = "Require a tag and its value on resources"
}


resource "azurerm_resource_group_policy_assignment" "require_cost_center_tag" {
  name                 = "require-cost-center-tag"
  display_name         = "Require Cost Center tag and its value on resources"
  description          = "Require Cost Center tag and its value on all resources in the resource group"
  resource_group_id    = azurerm_resource_group.az104_rg2.id
  policy_definition_id = data.azurerm_policy_definition.require_tag_value.id


  parameters = jsonencode({
    "tagName" = {
      "value" = "Cost Center"
    },
    "tagValue" = {
      "value" = "000"
    }
  })
}


data "azurerm_policy_definition" "inherit_tag_from_rg" {
  display_name = "Inherit a tag from the resource group if missing"
}


resource "azurerm_resource_group_policy_assignment" "inherit_cost_center_tag" {
  name                 = "inherit-cost-center-tag"
  display_name         = "Inherit the Cost Center tag and its value 000 from the resource group if missing"
  description          = "Inherit the Cost Center tag and its value 000 from the resource group if missing"
  resource_group_id    = azurerm_resource_group.az104_rg2.id
  policy_definition_id = data.azurerm_policy_definition.inherit_tag_from_rg.id


  parameters = jsonencode({
    "tagName" = {
      "value" = "Cost Center"
    }
  })


  location = azurerm_resource_group.az104_rg2.location


  identity {
    type = "SystemAssigned"
  }
}


resource "azurerm_management_lock" "rg_lock" {
  name       = "rg-lock"
  scope      = azurerm_resource_group.az104_rg2.id
  lock_level = "CanNotDelete"
  notes      = "Prevents accidental deletion of the resource group az104-rg2."
}


output "resource_group_id" {
  value = azurerm_resource_group.az104_rg2.id
}


output "require_policy_assignment_id" {
  value = azurerm_resource_group_policy_assignment.require_cost_center_tag.id
}


output "inherit_policy_assignment_id" {
  value = azurerm_resource_group_policy_assignment.inherit_cost_center_tag.id
}


output "resource_lock_id" {
  value = azurerm_management_lock.rg_lock.id
}
