output "private_vnet" {
  description = "The private VNET, CIDR, and any other details required as a sub attribute."
  value       = azurerm_virtual_network.az_vnet
}
output "public_vnet" {
  description = "The public VNET, CIDR, and any other details required as a sub attribute."
  value       = azurerm_virtual_network.az_public_vnet
}
output "platforms_subnet" {
  description = "Subnet ID, CIDR, and any other details required as a sub attribute of Platforms services subnets"
  value       = var.private_platform_subnet == null && var.custom_vnet == true ? null : azurerm_subnet.private_plat_subnet[0]
}

output "private_dynamic_subnet" {
  description = "Subnet ID, CIDR, and any other details required as a sub attribute of general Private subnets."
  value       = var.private_dynamic_subnet == null && var.custom_vnet == true ? null : azurerm_subnet.private_dyn_subnet[0]
}

output "private_static_subnet" {
  description = "Subnet ID, CIDR, and any other details required as a sub attribute of Private subnets that require a static IP address."
  value       = var.private_static_subnet == null && var.custom_vnet == true ? null : azurerm_subnet.private_stat_subnet[0]
}

output "private_db_subnet" {
  description = "Subnet ID, CIDR, and any other details required as a sub attribute of Database subnets."
  value       = var.private_db_subnet == null && var.custom_vnet == true ? null : azurerm_subnet.private_db_subnet[0]
}

output "ase_subnet" {
  description = "Subnet ID, CIDR, and any other details required as a sub attribute of Database subnets."
  value       = var.ase_subnet == null && var.custom_vnet == true ? null : azurerm_subnet.ase_subnet[0]
}

output "sqlmi_subnet" {
  description = "Subnet ID, CIDR, and any other details required as a sub attribute of SQL Managed Instance subnets."
  value       = var.sqlmi_subnet == null && var.custom_vnet == true ? null : azurerm_subnet.sqlmi_subnet[0]
}

output "custom_subnets" {
  description = "Subnet ID, CIDR, and any other details required as a sub attribute of custom specified subnets."
  value       = var.custom_subnets == {} ? null : azurerm_subnet.custom_subnets[*]
}

output "public_subnet" {
  description = "Subnet ID, CIDR, and any other details required as a sub attribute of Public general subnets."
  value       = azurerm_subnet.public_subnet
}

output "app_gateway_subnet" {
  description = "Subnet ID, CIDR, and any other details required as a sub attribute of Application Gatewat subnets."
  value       = azurerm_subnet.app_gw_subnet
}
