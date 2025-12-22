# ========================================
# Azure Lab 05 - Intersite Connectivity
# Terraform Configuration
# ========================================

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

# ========================================
# Variables
# ========================================

variable "admin_username" {
  description = "Admin username for VMs"
  type        = string
  default     = "localadmin"
}

variable "admin_password" {
  description = "Admin password for VMs"
  type        = string
  sensitive   = true
  default     = "YzkspXXBxrYVJ1MqNiIYD9RTx7kjZr0hAz/z0vji"  
}

# ========================================
# Resource Group
# ========================================

resource "azurerm_resource_group" "lab05" {
  name     = "az104-rg5"
  location = "Sweden Central"
}

# ========================================
# Core Services Virtual Network
# ========================================

resource "azurerm_virtual_network" "core_services" {
  name                = "CoreServicesVnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.lab05.location
  resource_group_name = azurerm_resource_group.lab05.name
}

resource "azurerm_subnet" "core" {
  name                 = "Core"
  resource_group_name  = azurerm_resource_group.lab05.name
  virtual_network_name = azurerm_virtual_network.core_services.name
  address_prefixes     = ["10.0.0.0/24"]
}

resource "azurerm_subnet" "perimeter" {
  name                 = "perimeter"
  resource_group_name  = azurerm_resource_group.lab05.name
  virtual_network_name = azurerm_virtual_network.core_services.name
  address_prefixes     = ["10.0.1.0/24"]
}

# ========================================
# Manufacturing Virtual Network
# ========================================

resource "azurerm_virtual_network" "manufacturing" {
  name                = "ManufacturingVnet"
  address_space       = ["172.16.0.0/16"]
  location            = azurerm_resource_group.lab05.location
  resource_group_name = azurerm_resource_group.lab05.name
}

resource "azurerm_subnet" "manufacturing" {
  name                 = "Manufacturing"
  resource_group_name  = azurerm_resource_group.lab05.name
  virtual_network_name = azurerm_virtual_network.manufacturing.name
  address_prefixes     = ["172.16.0.0/24"]
}

# ========================================
# Network Security Group for CoreServicesVM
# ========================================

resource "azurerm_network_security_group" "core_services" {
  name                = "CoreServicesVM-nsg"
  location            = azurerm_resource_group.lab05.location
  resource_group_name = azurerm_resource_group.lab05.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ========================================
# Network Security Group for ManufacturingVM
# ========================================

resource "azurerm_network_security_group" "manufacturing" {
  name                = "ManufacturingVM-nsg"
  location            = azurerm_resource_group.lab05.location
  resource_group_name = azurerm_resource_group.lab05.name

  security_rule {
    name                       = "AllowRDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# ========================================
# Network Interface for CoreServicesVM
# ========================================

resource "azurerm_network_interface" "core_services_vm" {
  name                = "CoreServicesVM-nic"
  location            = azurerm_resource_group.lab05.location
  resource_group_name = azurerm_resource_group.lab05.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.core.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "core_services" {
  network_interface_id      = azurerm_network_interface.core_services_vm.id
  network_security_group_id = azurerm_network_security_group.core_services.id
}

# ========================================
# Network Interface for ManufacturingVM
# ========================================

resource "azurerm_network_interface" "manufacturing_vm" {
  name                = "ManufacturingVM-nic"
  location            = azurerm_resource_group.lab05.location
  resource_group_name = azurerm_resource_group.lab05.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.manufacturing.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_interface_security_group_association" "manufacturing" {
  network_interface_id      = azurerm_network_interface.manufacturing_vm.id
  network_security_group_id = azurerm_network_security_group.manufacturing.id
}

# ========================================
# CoreServicesVM Virtual Machine
# ========================================

resource "azurerm_windows_virtual_machine" "core_services" {
  name                = "CoreServicesVM"
  resource_group_name = azurerm_resource_group.lab05.name
  location            = azurerm_resource_group.lab05.location
  size                = "Standard_DS2_v3"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  
  network_interface_ids = [
    azurerm_network_interface.core_services_vm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}

# ========================================
# ManufacturingVM Virtual Machine
# ========================================

resource "azurerm_windows_virtual_machine" "manufacturing" {
  name                = "ManufacturingVM"
  resource_group_name = azurerm_resource_group.lab05.name
  location            = azurerm_resource_group.lab05.location
  size                = "Standard_DS2_v3"
  admin_username      = var.admin_username
  admin_password      = var.admin_password
  
  network_interface_ids = [
    azurerm_network_interface.manufacturing_vm.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }

  boot_diagnostics {
    storage_account_uri = null
  }
}

# ========================================
# Virtual Network Peering
# ========================================

resource "azurerm_virtual_network_peering" "core_to_manufacturing" {
  name                         = "CoreServicesVnet-to-ManufacturingVnet"
  resource_group_name          = azurerm_resource_group.lab05.name
  virtual_network_name         = azurerm_virtual_network.core_services.name
  remote_virtual_network_id    = azurerm_virtual_network.manufacturing.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

resource "azurerm_virtual_network_peering" "manufacturing_to_core" {
  name                         = "ManufacturingVnet-to-CoreServicesVnet"
  resource_group_name          = azurerm_resource_group.lab05.name
  virtual_network_name         = azurerm_virtual_network.manufacturing.name
  remote_virtual_network_id    = azurerm_virtual_network.core_services.id
  allow_virtual_network_access = true
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
}

# ========================================
# Route Table
# ========================================

resource "azurerm_route_table" "core_services" {
  name                          = "rt-CoreServices"
  location                      = azurerm_resource_group.lab05.location
  resource_group_name           = azurerm_resource_group.lab05.name
  disable_bgp_route_propagation = true

  route {
    name                   = "PerimetertoCore"
    address_prefix         = "10.0.0.0/16"
    next_hop_type          = "VirtualAppliance"
    next_hop_in_ip_address = "10.0.1.7"
  }
}

# ========================================
# Associate Route Table with Subnet
# ========================================

resource "azurerm_subnet_route_table_association" "core" {
  subnet_id      = azurerm_subnet.core.id
  route_table_id = azurerm_route_table.core_services.id
}

# ========================================
# Outputs
# ========================================

output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.lab05.name
}

output "core_services_vm_name" {
  description = "Name of CoreServicesVM"
  value       = azurerm_windows_virtual_machine.core_services.name
}

output "core_services_vm_private_ip" {
  description = "Private IP address of CoreServicesVM"
  value       = azurerm_network_interface.core_services_vm.private_ip_address
}

output "manufacturing_vm_name" {
  description = "Name of ManufacturingVM"
  value       = azurerm_windows_virtual_machine.manufacturing.name
}

output "manufacturing_vm_private_ip" {
  description = "Private IP address of ManufacturingVM"
  value       = azurerm_network_interface.manufacturing_vm.private_ip_address
}

output "peering_status" {
  description = "Virtual network peering IDs"
  value = {
    core_to_manufacturing = azurerm_virtual_network_peering.core_to_manufacturing.id
    manufacturing_to_core = azurerm_virtual_network_peering.manufacturing_to_core.id
  }
}

output "route_table_id" {
  description = "Route table ID"
  value       = azurerm_route_table.core_services.id
}

output "instructions" {
  description = "Next steps"
  value = <<-EOT
  
  ========================================
  Lab 05 Resources Created Successfully!
  ========================================
  
  To test connectivity:
  1. Get private IPs from outputs above
  2. Use Azure Portal -> VM -> Run Command -> RunPowerShellScript
  3. Run: Test-NetConnection <target-ip> -port 3389
  
  To view resources:
  az vm list -g ${azurerm_resource_group.lab05.name} --output table
  
  To destroy all resources:
  terraform destroy
  
  EOT
}
