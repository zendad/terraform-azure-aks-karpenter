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

  name_prefix  = "${var.environment}-${local.azure_regions_shortname[var.location]}"
  vnet_name    = "vnet-${local.name_prefix}"
  cluster_name = "aks-cluster-${local.name_prefix}"

  public_subnet_names  = [for i in range(1, 4) : "snet-public-${local.name_prefix}-${i}"]
  private_subnet_names = [for i in range(1, 4) : "snet-private-${local.name_prefix}-${i}"]

  # Public subnets
  public_subnet_cidrs = [
    cidrsubnet(var.vnet_cidr, 11, 0),
    cidrsubnet(var.vnet_cidr, 11, 1),
    cidrsubnet(var.vnet_cidr, 11, 2)
  ]

  # Private subnets
  private_subnet_cidrs = [
    cidrsubnet(var.vnet_cidr, 11, 3),
    cidrsubnet(var.vnet_cidr, 11, 4),
    cidrsubnet(var.vnet_cidr, 11, 5)
  ]

  # Count each type
  public_subnet_count  = length(local.public_subnet_names)
  private_subnet_count = length(local.private_subnet_names)

  # Split the flat list of subnet IDs from the module into slices
  public_subnet_id_list = slice(module.network.vnet_subnets, 0, local.public_subnet_count)
  private_subnet_id_list = slice(
    module.network.vnet_subnets,
    local.public_subnet_count,
  local.public_subnet_count + local.private_subnet_count)


  cluster_roles = [
    "aks-cluster-clusteradmin",
    "aks-cluster-clusteroperator",
    "aks-cluster-clusterviewer"
  ]

}