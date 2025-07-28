# aks module implementation
module "aks" {
  # checkov:skip=CKV_TF_1 reason="Using Terraform Registry with a pinned version instead of git hash"
  source     = "Azure/aks/azurerm"
  version    = "10.2.0"
  depends_on = [azurerm_resource_group.aks_rg]

  # Azure
  prefix              = local.prefix
  resource_group_name = azurerm_resource_group.aks_rg.name
  location            = var.location
  tags                = var.default_tags

  # cluster
  cluster_name                 = local.cluster_name
  kubernetes_version           = var.kubernetes_version
  orchestrator_version         = var.kubernetes_version
  ebpf_data_plane              = var.ebpf_data_plane
  image_cleaner_enabled        = var.image_cleaner_enabled
  image_cleaner_interval_hours = var.image_cleaner_interval_hours
  automatic_channel_upgrade    = var.automatic_channel_upgrade
  maintenance_window           = var.maintenance_window
  private_cluster_enabled      = var.private_cluster_enabled

  # Networking
  net_profile_pod_cidr       = var.net_profile_pod_cidr
  net_profile_service_cidr   = var.net_profile_service_cidr
  net_profile_dns_service_ip = var.net_profile_dns_service_ip
  network_ip_versions        = var.network_ip_versions
  network_plugin_mode        = var.network_plugin_mode
  network_plugin             = var.network_plugin
  network_policy             = var.network_policy
  network_contributor_role_assigned_subnet_ids = zipmap(
    [for i in range(local.private_subnet_count) : "private-subnet-${i}"],
    slice(module.network.vnet_subnets, local.public_subnet_count, local.public_subnet_count + local.private_subnet_count)
  )

  # Default Node Pool
  enable_auto_scaling          = var.enable_auto_scaling
  agents_availability_zones    = var.agents_availability_zones
  temporary_name_for_rotation  = var.temporary_name_for_rotation
  agents_tags                  = var.default_tags
  agents_pool_name             = var.agents_pool_name
  agents_labels                = var.agents_labels
  agents_type                  = var.agents_type
  agents_count                 = var.agents_count
  agents_min_count             = var.agents_min_count
  agents_max_count             = var.agents_max_count
  agents_size                  = var.agents_size
  os_disk_size_gb              = var.os_disk_size_gb
  only_critical_addons_enabled = var.only_critical_addons_enabled
  vnet_subnet = {
    id = local.default_nodepool_subnet_id
  }
  node_resource_group = local.nodepool_resource_group_name

  # Vault
  key_vault_secrets_provider_enabled = var.key_vault_secrets_provider_enabled
  enable_host_encryption             = var.enable_host_encryption
  disk_encryption_set_id             = azurerm_disk_encryption_set.node.id
  kms_key_vault_key_id               = azurerm_key_vault.vault.id

  # Access
  rbac_aad_tenant_id                = var.rbac_aad_tenant_id
  rbac_aad_azure_rbac_enabled       = var.rbac_aad_azure_rbac_enabled
  workload_identity_enabled         = var.workload_identity_enabled
  oidc_issuer_enabled               = var.oidc_issuer_enabled
  identity_type                     = var.identity_type
  role_based_access_control_enabled = var.role_based_access_control_enabled

  # Logs
  cluster_log_analytics_workspace_name = local.cluster_name
  log_analytics_workspace_enabled      = var.log_analytics_workspace_enabled
}