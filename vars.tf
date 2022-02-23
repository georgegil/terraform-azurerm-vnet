variable "tags" {
  description = "Please reference the current tagging policy for required tags and allowed values."
  type        = map(string)
}

variable "rg_name" {
  description = "Resource Group Name where VNET will be deployed."
  type        = string
  default     = "Networking"
}

variable "location" {
  description = "Geographic location where VNET will be deployed. Allowed values are: `South Central US, East US 2, West US 2, UK South, West Europe, East Asia, Australia East, Australia Southeast, Southeast Asia, UK West.`"
  type        = string
}

variable "dns_servers" {
  description = "DNS servers of the VNET."
  type        = list(string)
}

variable "vnet_cidr" {
  description = "The subnet  of the VNET. Example value 192.168.0.0/16 (must be at least /20 subnet)."
  type        = list(string)
}

variable "public_vnet_cidr" {
  description = "The subnet  of the Public VNET. Example value 192.168.255.0/24 (must be at least /24 subnet)."
  type        = list(string)
  default     = ["192.168.255.0/24"]
}

variable "subnet_service_endpoint" {
  description = "Subnet Service Endpoints, as per [Microsoft](https://docs.microsoft.com/en-us/azure/virtual-network/virtual-network-service-endpoints-overview)."
  type        = list(string)
  default     = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault", "Microsoft.Sql", "Microsoft.Storage", "Microsoft.ContainerRegistry", "Microsoft.EventHub"]
}

variable "nva_ip" {
  description = "Network Virtual Appliance IP address, if needed to configure local egress from the VNET."
  type        = string
  default     = null
}

variable "transit_vnet_id" {
  description = "The ID of the VNET, except for the VNET name. The default value should be used unless a rare exception."
  type        = string
}

variable "custom_vnet" {
  description = "If this is a custom VNET in a dedicated subscription, this makes standard subnets optional."
  type        = bool
  default     = "false"
}

variable "pvt_link_policy" {
  description = "Sets a subnet to have private policies enabled or disabled."
  type        = bool
  default     = true
}

variable "private_dynamic_subnet" {
  description = "Details for provisioning and subnet size for Private Dynamic subnet."
  type        = list(string)
  default     = null
}

variable "private_static_subnet" {
  description = "Details for provisioning and subnet size for Private Static subnet."
  type        = list(string)
  default     = null
}

variable "private_platform_subnet" {
  description = "Details for provisioning and subnet size for Private Platform services subnet."
  type        = list(string)
  default     = null
}

variable "private_db_subnet" {
  description = "Details for provisioning and subnet size for Private database subnet."
  type        = list(string)
  default     = null
}

variable "ase_subnet" {
  description = "Details for provisioning and subnet size for Application Serive Environments."
  type        = list(string)
  default     = null
}

variable "sqlmi_subnet" {
  description = "Details for provisioning and subnet size for SQL Managed instance."
  type        = list(string)
  default     = null
}


variable "custom_subnets" {
  description = "Any Custom subnets and delegation required."
  type = map(object({
    cidr              = list(string)
    delegation        = set(string)
    service_endpoints = list(string)
  }))
  default = {}
}

variable "front_door_routing" {
  description = "Provision routes for Front Door capabilities in the private subnets."
  type        = bool
  default     = false
}
