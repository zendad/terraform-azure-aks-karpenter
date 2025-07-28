# client config
data "azurerm_client_config" "current" {}


# Get AD groups
data "azuread_group" "k8s_groups" {
  depends_on   = [module.aks]
  for_each     = toset(local.cluster_roles)
  display_name = each.key
}

# get default nodepool RG
data "azurerm_resource_group" "default_nodepool" {
  depends_on = [module.aks]
  name       = local.nodepool_resource_group_name
}

