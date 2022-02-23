###### Azue VNET ##################
resource "azurerm_virtual_network" "az_vnet" {
  name                = "${local.vnet_prefix}-private"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.vnet_cidr
  dns_servers         = var.dns_servers

  tags = var.tags
}

resource "azurerm_virtual_network" "az_public_vnet" {
  name                = "${local.vnet_prefix}-public"
  location            = var.location
  resource_group_name = var.rg_name
  address_space       = var.public_vnet_cidr



  tags = var.tags
}

####### peerlink to hub network ##########

resource "azurerm_virtual_network_peering" "hub_peer" {
  name                         = "${local.vnet_prefix}-transit-link"
  resource_group_name          = var.rg_name
  virtual_network_name         = azurerm_virtual_network.az_vnet.name
  remote_virtual_network_id    = var.transit_vnet_id
  allow_forwarded_traffic      = true
  allow_gateway_transit        = false
  allow_virtual_network_access = true
  use_remote_gateways          = true
}

####### peerlink to public network ##########

resource "azurerm_virtual_network_peering" "link_to_public" {
  name                         = "${local.vnet_prefix}-link-to-public"
  resource_group_name          = var.rg_name
  virtual_network_name         = azurerm_virtual_network.az_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.az_public_vnet.id
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  allow_virtual_network_access = true
  use_remote_gateways          = false
}

resource "azurerm_virtual_network_peering" "link_to_private" {
  name                         = "${local.vnet_prefix}-link-to-private"
  resource_group_name          = var.rg_name
  virtual_network_name         = azurerm_virtual_network.az_public_vnet.name
  remote_virtual_network_id    = azurerm_virtual_network.az_vnet.id
  allow_forwarded_traffic      = false
  allow_gateway_transit        = false
  allow_virtual_network_access = true
  use_remote_gateways          = false
}

######### subnets #######

resource "azurerm_subnet" "app_gw_subnet" {
  name                 = "ApplicationGatewaySubnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.az_public_vnet.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.az_public_vnet.address_space[0], 3, 0)]

  service_endpoints = [
    "Microsoft.KeyVault"
  ]
}

resource "azurerm_subnet" "public_subnet" {
  name                 = "PublicSubnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.az_public_vnet.name
  address_prefixes     = [cidrsubnet(azurerm_virtual_network.az_public_vnet.address_space[0], 3, 1)]
}

resource "azurerm_subnet" "private_dyn_subnet" {
  count                                          = var.private_dynamic_subnet == null && var.custom_vnet == true ? 0 : 1
  name                                           = "PrivateDynamicSubnet"
  resource_group_name                            = var.rg_name
  virtual_network_name                           = azurerm_virtual_network.az_vnet.name
  address_prefixes                               = var.private_dynamic_subnet == null ? [cidrsubnet(azurerm_virtual_network.az_vnet.address_space[0], local.subnetsize_bit, 0)] : var.private_dynamic_subnet
  service_endpoints                              = var.subnet_service_endpoint
  enforce_private_link_endpoint_network_policies = var.pvt_link_policy
}

resource "azurerm_subnet" "private_stat_subnet" {
  count                                          = var.private_static_subnet == null && var.custom_vnet == true ? 0 : 1
  name                                           = "PrivateStaticSubnet"
  resource_group_name                            = var.rg_name
  virtual_network_name                           = azurerm_virtual_network.az_vnet.name
  address_prefixes                               = var.private_static_subnet == null ? [cidrsubnet(azurerm_virtual_network.az_vnet.address_space[0], local.subnetsize_bit, 1)] : var.private_static_subnet
  service_endpoints                              = var.subnet_service_endpoint
  enforce_private_link_endpoint_network_policies = var.pvt_link_policy
}

resource "azurerm_subnet" "private_plat_subnet" {
  count                                          = var.private_platform_subnet == null && var.custom_vnet == true ? 0 : 1
  name                                           = "PlatformServicesSubnet"
  resource_group_name                            = var.rg_name
  virtual_network_name                           = azurerm_virtual_network.az_vnet.name
  address_prefixes                               = var.private_platform_subnet == null ? [cidrsubnet(azurerm_virtual_network.az_vnet.address_space[0], local.subnetsize_bit, 2)] : var.private_platform_subnet
  service_endpoints                              = var.subnet_service_endpoint
  enforce_private_link_endpoint_network_policies = var.pvt_link_policy
}

resource "azurerm_subnet" "private_db_subnet" {
  count                                          = var.private_db_subnet == null && var.custom_vnet == true ? 0 : 1
  name                                           = "PrivateDatabaseSubnet"
  resource_group_name                            = var.rg_name
  virtual_network_name                           = azurerm_virtual_network.az_vnet.name
  address_prefixes                               = var.private_db_subnet == null ? [cidrsubnet(azurerm_virtual_network.az_vnet.address_space[0], local.subnetsize_bit, 3)] : var.private_db_subnet
  service_endpoints                              = var.subnet_service_endpoint
  enforce_private_link_endpoint_network_policies = var.pvt_link_policy
}

resource "azurerm_subnet" "ase_subnet" {
  count                = var.ase_subnet == null && var.custom_vnet == true ? 0 : 1
  name                 = "ASESubnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.az_vnet.name
  address_prefixes     = var.ase_subnet == null ? [cidrsubnet(azurerm_virtual_network.az_vnet.address_space[0], local.subnetsize_bit, 4)] : var.ase_subnet

  delegation {
    name = "AseDelegation"
    service_delegation {
      name = "Microsoft.Web/hostingEnvironments"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/action"
      ]
    }
  }

  service_endpoints = var.subnet_service_endpoint
}

resource "azurerm_subnet" "sqlmi_subnet" {
  count                = var.sqlmi_subnet == null && var.custom_vnet == true ? 0 : 1
  name                 = "SQLManagedInstanceSubnet"
  resource_group_name  = var.rg_name
  virtual_network_name = azurerm_virtual_network.az_vnet.name
  address_prefixes     = var.sqlmi_subnet == null ? [cidrsubnet(azurerm_virtual_network.az_vnet.address_space[0], local.subnetsize_bit, 5)] : var.sqlmi_subnet

  delegation {
    name = "sqlmidelegation"
    service_delegation {
      name    = "Microsoft.Sql/managedInstances"
      actions = ["Microsoft.Network/virtualNetworks/subnets/join/action", "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action", "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"]
    }
  }

  service_endpoints = var.subnet_service_endpoint
}

resource "azurerm_network_security_group" "sql_mi" {
  count               = var.sqlmi_subnet == null && var.custom_vnet == true ? 0 : 1
  name                = "${local.vnet_prefix}-sqlmi-sg"
  location            = var.location
  resource_group_name = var.rg_name
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      security_rule
    ]
  }
}

resource "azurerm_subnet_network_security_group_association" "sg_assocation" {
  count                     = var.sqlmi_subnet == null && var.custom_vnet == true ? 0 : 1
  subnet_id                 = azurerm_subnet.sqlmi_subnet[0].id
  network_security_group_id = azurerm_network_security_group.sql_mi[0].id
}

resource "azurerm_route_table" "sqlmi_routetable" {
  count                         = var.sqlmi_subnet == null && var.custom_vnet == true ? 0 : 1
  name                          = "${local.vnet_prefix}-sqlmi-route-table"
  location                      = var.location
  resource_group_name           = var.rg_name
  disable_bgp_route_propagation = true

  tags = var.tags
}

resource "azurerm_subnet_route_table_association" "rt_assocation" {
  count          = var.sqlmi_subnet == null && var.custom_vnet == true ? 0 : 1
  subnet_id      = azurerm_subnet.sqlmi_subnet[0].id
  route_table_id = azurerm_route_table.sqlmi_routetable[0].id
}

resource "azurerm_subnet" "custom_subnets" {
  for_each                                       = var.custom_subnets
  name                                           = each.key
  resource_group_name                            = var.rg_name
  virtual_network_name                           = azurerm_virtual_network.az_vnet.name
  address_prefixes                               = each.value.cidr
  service_endpoints                              = each.value.service_endpoints == [] ? var.subnet_service_endpoint : each.value.service_endpoints
  enforce_private_link_endpoint_network_policies = var.pvt_link_policy

  dynamic "delegation" {
    for_each = each.value.delegation
    content {
      name = "delegation"
      service_delegation {
        name = delegation.key
      }
    }
  }
}

####### routing ########

resource "azurerm_route_table" "services" {
  name                          = "${local.vnet_prefix}-route-table"
  location                      = var.location
  resource_group_name           = var.rg_name
  disable_bgp_route_propagation = false

  tags = var.tags

}

resource "azurerm_route" "kms" {
  name                = "kms-activation"
  resource_group_name = var.rg_name
  route_table_name    = azurerm_route_table.services.name
  address_prefix      = "23.102.135.246/32"
  next_hop_type       = "Internet"
}

resource "azurerm_route" "nva_pvt_rt" {
  count                  = var.nva_ip == null ? 0 : 1
  name                   = "DefaultRoute"
  resource_group_name    = var.rg_name
  route_table_name       = azurerm_route_table.services.name
  address_prefix         = "0.0.0.0/0"
  next_hop_type          = "VirtualAppliance"
  next_hop_in_ip_address = var.nva_ip
}

resource "azurerm_route" "fd" {
  count               = var.front_door_routing ? length(local.fd_routes) : 0
  name                = "FrontDoorRoute-${count.index}"
  resource_group_name = var.rg_name
  route_table_name    = azurerm_route_table.services.name
  address_prefix      = local.fd_routes[count.index]
  next_hop_type       = "Internet"
}

resource "azurerm_subnet_route_table_association" "private_dyn_subnet" {
  count          = var.private_dynamic_subnet == null && var.custom_vnet == true ? 0 : 1
  subnet_id      = azurerm_subnet.private_dyn_subnet[0].id
  route_table_id = azurerm_route_table.services.id
}

resource "azurerm_subnet_route_table_association" "private_stat_subnet" {
  count          = var.private_static_subnet == null && var.custom_vnet == true ? 0 : 1
  subnet_id      = azurerm_subnet.private_stat_subnet[0].id
  route_table_id = azurerm_route_table.services.id
}

resource "azurerm_subnet_route_table_association" "private_plat_subnet" {
  count          = var.private_platform_subnet == null && var.custom_vnet == true ? 0 : 1
  subnet_id      = azurerm_subnet.private_plat_subnet[0].id
  route_table_id = azurerm_route_table.services.id
}

resource "azurerm_subnet_route_table_association" "private_db_subnet" {
  count          = var.private_db_subnet == null && var.custom_vnet == true ? 0 : 1
  subnet_id      = azurerm_subnet.private_db_subnet[0].id
  route_table_id = azurerm_route_table.services.id
}

resource "azurerm_subnet_route_table_association" "custom_subnet" {
  for_each       = var.custom_subnets
  subnet_id      = azurerm_subnet.custom_subnets[each.key].id
  route_table_id = azurerm_route_table.services.id
}

locals {
  ###### region prefix calculation
  vnet_prefix = "${lower(var.tags.Environment)}${lookup(local.region_code, var.location, "null")}"

  region_code = {
    "South Central US"    = "ussc"
    "East US 2"           = "use2"
    "West US 2"           = "usw2"
    "UK South"            = "ukso"
    "UK West"             = "ukwe"
    "West Europe"         = "euwe"
    "East Asia"           = "aphk"
    "Australia East"      = "auea"
    "Australia Southeast" = "ause"
    "Southeast Asia"      = "apse"
    "Japan East"          = "jpea"
  }

  # subnet calculation
  subnetsize_bit = 24 - tonumber(split("/", var.vnet_cidr[0])[1])

  

  # FrontDoor backend routes, to be replaced by future Service Tag routing
  fd_routes = [
    "13.73.248.16/29",
    "20.36.120.104/29",
    "20.37.64.104/29",
    "20.37.156.120/29",
    "20.37.195.0/29",
    "20.37.224.104/29",
    "20.38.84.72/29",
    "20.38.136.104/29",
    "20.39.11.8/29",
    "20.41.4.88/29",
    "20.41.64.120/29",
    "20.41.192.104/29",
    "20.42.4.120/29",
    "20.42.129.152/29",
    "20.42.224.104/29",
    "20.43.41.136/29",
    "20.43.65.128/29",
    "20.43.130.80/29",
    "20.45.112.104/29",
    "20.45.192.104/29",
    "20.72.18.248/29",
    "20.150.160.96/29",
    "20.189.106.112/29",
    "20.192.161.104/29",
    "20.192.225.48/29",
    "40.67.48.104/29",
    "40.74.30.72/29",
    "40.80.56.104/29",
    "40.80.168.104/29",
    "40.80.184.120/29",
    "40.82.248.248/29",
    "40.89.16.104/29",
    "51.12.41.8/29",
    "51.12.193.8/29",
    "51.104.25.128/29",
    "51.105.80.104/29",
    "51.105.88.104/29",
    "51.107.48.104/29",
    "51.107.144.104/29",
    "51.120.40.104/29",
    "51.120.224.104/29",
    "51.137.160.112/29",
    "51.143.192.104/29",
    "52.136.48.104/29",
    "52.140.104.104/29",
    "52.150.136.120/29",
    "52.228.80.120/29",
    "102.133.56.88/29",
    "102.133.216.88/29",
    "147.243.0.0/16",
    "191.233.9.120/29",
    "191.235.225.128/29"
  ]
}
