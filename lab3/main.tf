# --- БЛОК ПРОВАЙДЕРА ---
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> 3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

# --- ЗМІННІ (Для гнучкості, як у Task 5) ---
variable "resource_group_name" {
  default = "az104-rg3"
}

variable "location" {
  default = "West Europe"
}

# --- РЕСУРСИ ---

# Створення групи ресурсів
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name
  location = var.location
}

# Task 1: Створення керованого диска az104-disk1 (Standard HDD)
resource "azurerm_managed_disk" "disk1" {
  name                 = "az104-disk1"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
}

# Task 2: Створення диска az104-disk2 (демонстрація повторюваності)
resource "azurerm_managed_disk" "disk2" {
  name                 = "az104-disk2"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
}

# Task 3: Диск az104-disk3 (як через PowerShell в лабі)
resource "azurerm_managed_disk" "disk3" {
  name                 = "az104-disk3"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
}

# Task 4: Диск az104-disk4 (як через Azure CLI в лабі)
resource "azurerm_managed_disk" "disk4" {
  name                 = "az104-disk4"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = 32
}

# Task 5: Диск az104-disk5 (SSD, як у завданні з Bicep)
resource "azurerm_managed_disk" "disk5" {
  name                 = "az104-disk5"
  location             = azurerm_resource_group.rg.location
  resource_group_name  = azurerm_resource_group.rg.name
  storage_account_type = "StandardSSD_LRS" # Зміна типу на SSD
  create_option        = "Empty"
  disk_size_gb         = 32
}

# --- ВИВІД (Outputs) ---
output "disk_ids" {
  value = [
    azurerm_managed_disk.disk1.id,
    azurerm_managed_disk.disk5.id
  ]
}
