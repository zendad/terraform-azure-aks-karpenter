# random string
resource "random_string" "suffix" {
  length  = 4
  upper   = false
  special = false
}

# locals variables
locals {
  azure_regions_shortname = {
    "australiaeast"      = "aue"
    "australiasoutheast" = "aus"
    "brazilsouth"        = "brs"
    "canadacentral"      = "cac"
    "canadaeast"         = "cae"
    "centralindia"       = "cin"
    "centralus"          = "cus"
    "eastasia"           = "eas"
    "eastus"             = "eus"
    "eastus2"            = "eus2"
    "francecentral"      = "frc"
    "germanywestcentral" = "gwc"
    "japaneast"          = "jpe"
    "japanwest"          = "jpw"
    "koreacentral"       = "krc"
    "northcentralus"     = "ncus"
    "northeurope"        = "neu"
    "norwayeast"         = "nwe"
    "southafricanorth"   = "san"
    "southcentralus"     = "scus"
    "southindia"         = "sin"
    "southeastasia"      = "sea"
    "swedencentral"      = "sec"
    "switzerlandnorth"   = "chn" # Yes, "chn" is used even though it's odd
    "uaenorth"           = "uan"
    "uksouth"            = "uks"
    "ukwest"             = "ukw"
    "westeurope"         = "weu"
    "westus"             = "wus"
    "westus2"            = "wus2"
    "westus3"            = "wus3"
  }

  name_prefix                  = "${var.environment}-${local.azure_regions_shortname[var.location]}"
  prefix                       = "aks"
  vnet_name                    = "vnet-${local.name_prefix}"
  cluster_name                 = "aks-cluster-${local.name_prefix}"
  nodepool_resource_group_name = "rg-nodepool-${local.name_prefix}"

  # Public subnets
  public_subnet_cidrs = [
    cidrsubnet(var.vnet_cidr, 11, 0) # 5 bits added to /24 = /29, but we want /27, so adjust base cidr accordingly
  ]

  # Private subnets
  private_subnet_cidrs = [
    cidrsubnet(var.vnet_cidr, 9, 1) # /25 subnet
  ]

  public_subnet_names  = [for idx, cidr in local.public_subnet_cidrs : "snet-public-${local.name_prefix}-${idx + 1}"]
  private_subnet_names = [for idx, cidr in local.private_subnet_cidrs : "snet-private-${local.name_prefix}-${idx + 1}"]

  # Count each type
  public_subnet_count  = length(local.public_subnet_names)
  private_subnet_count = length(local.private_subnet_names)

  # Split the flat list of subnet IDs from the module into slices
  subnet_name_to_id_map = zipmap(
    concat(local.private_subnet_names, local.public_subnet_names),
    module.network.vnet_subnets
  )

  private_subnet_id_list = [
    for sn_name in local.private_subnet_names :
    local.subnet_name_to_id_map[sn_name]
  ]

  public_subnet_id_list = [
    for sn_name in local.public_subnet_names :
    local.subnet_name_to_id_map[sn_name]
  ]

  default_nodepool_subnet_id = local.subnet_name_to_id_map[local.private_subnet_names[0]]

  cluster_roles = [
    "aks-cluster-clusteradmin",
    "aks-cluster-clusteroperator",
    "aks-cluster-clusterviewer",
    "aks-cluster-namespaceadmin",
    "aks-cluster-namespaceoperator",
    "aks-cluster-namespaceviewer"
  ]

  clusterrole_groups = {
    for role in local.cluster_roles :
    role => {
      id = data.azuread_group.k8s_groups[role].object_id
    }
  }

  karpenter_log_level = "info"

  key_expiration_date = timeadd("${formatdate("YYYY-MM-DD", timestamp())}T00:00:00Z", var.key_expiration_offset)

}