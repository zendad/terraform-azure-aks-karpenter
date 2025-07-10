# vnet and subnets for aks cluster
module "network" {
  depends_on          = [azurerm_resource_group.aks_rg]
  source              = "Azure/network/azurerm"
  version             = "5.3.0"
  use_for_each        = true
  resource_group_name = azurerm_resource_group.aks_rg.name
  vnet_name           = local.vnet_name
  address_spaces      = [var.vnet_cidr]
  subnet_prefixes     = concat(local.public_subnet_cidrs, local.private_subnet_cidrs)
  subnet_names        = concat(local.public_subnet_names, local.private_subnet_names)
  tags                = var.default_tags
}