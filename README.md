# terraform-azurerm-vnet

Module to deploy a VNET, and peer into a transit VNET in different subscription.

## Example Usage

```hcl
module "azure_vnet" {
  source = "github.com/georgegil/terraform-azurerm-vnet.git?ref=<current version>"

  tags = {
    "Tag_1" = "Value_1"
    "Tag_2" = "Value_2"
    "Tag_3" = "Value_3"
  }

  rg_name                 = "Networking_RG"
  location                = "West Europe"
  dns_servers             = ["10.8.8.20", "10.11.8.19"]
  vnet_cidr               = ["10.120.0.0/23", "10.120.2.0/24"]
  subnet_service_endpoint = ["Microsoft.AzureCosmosDB", "Microsoft.KeyVault"]
  nva_ip                  = "10.120.64.13"
  transit_vnet_id         = "/subscriptions/9258877224884/resourceGroups/Networking-Transit/providers/Microsoft.Network/virtualNetworks/prod-transit-vnet"
  custom_vnet             = true
  pvt_link_policy         = false
  front_door_routing      = false

  private_dynamic_subnet  = ["10.120.0.0/26"]
  private_static_subnet   = ["10.120.0.64/26"]
  private_platform_subnet = ["10.120.0.128/26"]
  private_db_subnet       = ["10.120.0.192/26"]

  custom_subnets = {
    private-services   = ["10.120.4.0/24"]
    private-kubernetes = ["10.120.2.0/23"]
  }
}
```

where `<current version>` is the most recent release.

## Related Links

- [Azure Locations](https://azure.microsoft.com/en-us/global-infrastructure/regions/)
- [IP Subnet Splitter](https://www.davidc.net/sites/default/subnets/subnets.html)


## Development

Feel free to create a branch and submit a pull request to make changes to the module.