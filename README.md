# terraform-azure-aks-karpenter
NOT THIS IS STILL IN DEVELOPMENT
# AKS Cluster Creation
This repository contains the implementation of the (Azure/aks/azurerm)[Azure/aks/azurerm] Terraform module to provision an Azure Kubernetes Service (AKS) cluster with karpenter for node pools and optional features like OIDC and KMS encryption. This also implemements the necessary resource groups,virtual network (VNet) and subnets for the AKS cluster.

# VNet and Subnets for AKS Cluster
The following provisions a Virtual Network and multiple subnets required for the AKS cluster, including node, pod, public, and private subnets.
```hcl
module "network" {
  depends_on          = [azurerm_resource_group.aks_rg]
  source              = "Azure/network/azurerm"
  version             = "5.3.0"
  use_for_each        = true
  resource_group_name = azurerm_resource_group.aks_rg.name
  vnet_name           = local.vnet_name
  address_spaces      = [var.vnet_cidr]
  subnet_prefixes     = concat(local.node_subnet_cidrs, local.pod_subnet_cidrs, local.public_subnet_cidrs, local.private_subnet_cidrs)
  subnet_names        = concat(local.node_subnet_names, local.pod_subnet_names, local.public_subnet_names, local.private_subnet_names)
  tags                = var.default_tags
}
```

# AKS Deployment
This module provisions the AKS cluster using the official Azure AKS Terraform module with autoscaling, node pools, KMS encryption, and more.
```hcl
module "aks" {

  source                               = "Azure/aks/azurerm"
  version                              = "10.1.0"
  depends_on                           = [azurerm_resource_group.aks_rg]
  prefix                               = "aks-${local.name_prefix}"
  ebpf_data_plane                      = var.ebpf_data_plane
  resource_group_name                  = azurerm_resource_group.aks_rg.name
  cluster_name                         = local.cluster_name
  location                             = var.location
  role_based_access_control_enabled    = var.role_based_access_control_enabled
  tags                                 = var.default_tags
  kubernetes_version                   = var.kubernetes_version
  orchestrator_version                 = var.kubernetes_version
  network_plugin                       = var.network_plugin
  network_policy                       = var.network_policy
  oidc_issuer_enabled                  = var.oidc_issuer_enabled
  enable_auto_scaling                  = var.enable_auto_scaling
  agents_availability_zones            = var.agents_availability_zones
  temporary_name_for_rotation          = var.temporary_name_for_rotation
  agents_tags                          = var.default_tags
  cluster_log_analytics_workspace_name = local.cluster_name
  agents_pool_name                     = var.agents_pool_name
  agents_labels                        = var.agents_labels
  agents_type                          = var.agents_type
  agents_count                         = var.agents_count
  agents_min_count                     = var.agents_min_count
  agents_max_count                     = var.agents_max_count
  agents_size                          = var.agents_size
  log_analytics_workspace_enabled      = var.log_analytics_workspace_enabled
  image_cleaner_enabled                = var.image_cleaner_enabled
  image_cleaner_interval_hours         = var.image_cleaner_interval_hours
  key_vault_secrets_provider_enabled   = var.key_vault_secrets_provider_enabled
  automatic_channel_upgrade            = var.automatic_channel_upgrade
  identity_type                        = var.identity_type
  net_profile_pod_cidr                 = var.net_profile_pod_cidr
  net_profile_service_cidr             = var.net_profile_service_cidr
  net_profile_dns_service_ip           = var.net_profile_dns_service_ip
  network_ip_versions                  = var.network_ip_versions
  network_plugin_mode                  = var.network_plugin_mode
  only_critical_addons_enabled         = var.only_critical_addons_enabled
  rbac_aad_tenant_id                   = var.rbac_aad_tenant_id
  rbac_aad_azure_rbac_enabled          = var.rbac_aad_azure_rbac_enabled
  workload_identity_enabled            = var.workload_identity_enabled
}
````

# Karpenter
Karpenter is implemented using (self-hosted)[https://github.com/Azure/karpenter-provider-azure?tab=readme-ov-file#using-karpenter-self-hosted] mode. This part is not fully automated.

## Karpenter Outstanding Issues
1. Automate configuration of karpenter resources for nodepools
2. Complete Automation of the script to boostrap karpenter

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.7.0 |
| <a name="requirement_azuread"></a> [azuread](#requirement\_azuread) | ~> 3.0.0 |
| <a name="requirement_azurerm"></a> [azurerm](#requirement\_azurerm) | >= 3.107.0, < 4.0 |
| <a name="requirement_helm"></a> [helm](#requirement\_helm) | >= 2.8 |
| <a name="requirement_kubectl"></a> [kubectl](#requirement\_kubectl) | >= 1.7.0 |
| <a name="requirement_kubernetes"></a> [kubernetes](#requirement\_kubernetes) | ~> 2.35.0 |
| <a name="requirement_random"></a> [random](#requirement\_random) | 3.3.2 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_azuread"></a> [azuread](#provider\_azuread) | 3.0.2 |
| <a name="provider_azurerm"></a> [azurerm](#provider\_azurerm) | 3.117.1 |
| <a name="provider_helm"></a> [helm](#provider\_helm) | 3.0.2 |
| <a name="provider_null"></a> [null](#provider\_null) | 3.2.4 |
| <a name="provider_random"></a> [random](#provider\_random) | 3.3.2 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_aks"></a> [aks](#module\_aks) | Azure/aks/azurerm | 10.1.0 |
| <a name="module_network"></a> [network](#module\_network) | Azure/network/azurerm | 5.3.0 |

## Resources

| Name | Type |
|------|------|
| [azurerm_resource_group.aks_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.backend](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_resource_group.vault_rg](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group) | resource |
| [azurerm_role_assignment.karpenter_roles](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/role_assignment) | resource |
| [azurerm_storage_account.backend](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_account) | resource |
| [azurerm_storage_container.tfstate](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/storage_container) | resource |
| [azurerm_user_assigned_identity.karpenter_msi](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/user_assigned_identity) | resource |
| [helm_release.karpenter](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [helm_release.karpenter_crds](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release) | resource |
| [null_resource.karpenter_config](https://registry.terraform.io/providers/hashicorp/null/latest/docs/resources/resource) | resource |
| [random_string.suffix](https://registry.terraform.io/providers/hashicorp/random/3.3.2/docs/resources/string) | resource |
| [azuread_group.k8s_groups](https://registry.terraform.io/providers/hashicorp/azuread/latest/docs/data-sources/group) | data source |
| [azurerm_client_config.current](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/data-sources/client_config) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_account_replication_type"></a> [account\_replication\_type](#input\_account\_replication\_type) | The replication type of the storage account (e.g., LRS, GRS, ZRS) | `string` | `"LRS"` | no |
| <a name="input_account_tier"></a> [account\_tier](#input\_account\_tier) | The performance tier of the storage account (Standard or Premium) | `string` | `"Standard"` | no |
| <a name="input_agents_availability_zones"></a> [agents\_availability\_zones](#input\_agents\_availability\_zones) | List of Availability Zones for the AKS agent pool. Zones must be supported in the selected region and for the chosen VM size. Leave empty to disable zonal distribution. | `list(string)` | `null` | no |
| <a name="input_agents_count"></a> [agents\_count](#input\_agents\_count) | Specifies the number of agent nodes to provision. If null and autoscaling is enabled, min and max counts are used. | `number` | `null` | no |
| <a name="input_agents_labels"></a> [agents\_labels](#input\_agents\_labels) | A map of Kubernetes labels to apply to nodes in the default AKS node pool. Changing this value forces the node pool to be recreated. | `map(string)` | `{}` | no |
| <a name="input_agents_max_count"></a> [agents\_max\_count](#input\_agents\_max\_count) | The maximum number of agent nodes for the node pool when autoscaling is enabled. | `number` | `3` | no |
| <a name="input_agents_min_count"></a> [agents\_min\_count](#input\_agents\_min\_count) | The minimum number of agent nodes for the node pool when autoscaling is enabled. | `number` | `1` | no |
| <a name="input_agents_pool_name"></a> [agents\_pool\_name](#input\_agents\_pool\_name) | The name assigned to the default AKS agent node pool. This name must be unique within the AKS cluster and 3–12 characters long. | `string` | `"platformpool"` | no |
| <a name="input_agents_size"></a> [agents\_size](#input\_agents\_size) | The VM size to use for the agent node pool in the AKS cluster. | `string` | `"Standard_D2s_v3"` | no |
| <a name="input_agents_type"></a> [agents\_type](#input\_agents\_type) | Specifies the type of agent pool to use for the AKS cluster. Supported values are 'VirtualMachineScaleSets' (VMSS) and 'AvailabilitySet' (deprecated for new clusters). | `string` | `"VirtualMachineScaleSets"` | no |
| <a name="input_api_server_authorized_ip_ranges"></a> [api\_server\_authorized\_ip\_ranges](#input\_api\_server\_authorized\_ip\_ranges) | Set of authorized IP ranges for the API server | `set(string)` | `null` | no |
| <a name="input_automatic_channel_upgrade"></a> [automatic\_channel\_upgrade](#input\_automatic\_channel\_upgrade) | The automatic upgrade channel to use for the AKS cluster. Determines how the cluster is updated with newer Kubernetes versions.<br/>Allowed values:<br/>  - "patch"       → Only automatic patch updates within the same minor version.<br/>  - "stable"      → Recommended channel for general workloads. Upgrades through stable minor versions.<br/>  - "rapid"       → For testing the latest versions quickly.<br/>  - "node-image"  → Only the node OS and container runtime get updated, Kubernetes version stays the same.<br/>  - "none"        → Disables automatic upgrades. Manual upgrades are required. | `string` | `"patch"` | no |
| <a name="input_availability_zones"></a> [availability\_zones](#input\_availability\_zones) | List of availability zones to use | `list(string)` | `[]` | no |
| <a name="input_container_access_type"></a> [container\_access\_type](#input\_container\_access\_type) | The access level of the storage container (private, blob, or container) | `string` | `"private"` | no |
| <a name="input_default_tags"></a> [default\_tags](#input\_default\_tags) | Default tags for all resources | `map(string)` | `{}` | no |
| <a name="input_ebpf_data_plane"></a> [ebpf\_data\_plane](#input\_ebpf\_data\_plane) | Specifies the eBPF data plane implementation for the AKS cluster.<br/>Allowed values:<br/>  - "none"     : Disable eBPF data plane (default kube-proxy)<br/>  - "cilium"   : Enable Cilium as the eBPF data plane | `string` | `"none"` | no |
| <a name="input_enable_auto_scaling"></a> [enable\_auto\_scaling](#input\_enable\_auto\_scaling) | Enable cluster autoscaler for the AKS node pool to automatically adjust the number of nodes based on workload demand. | `bool` | `true` | no |
| <a name="input_environment"></a> [environment](#input\_environment) | Deployment environment | `string` | `""` | no |
| <a name="input_identity_type"></a> [identity\_type](#input\_identity\_type) | Specifies the type of managed identity used for the AKS cluster. Allowed values are 'SystemAssigned' or 'UserAssigned'. | `string` | `"SystemAssigned"` | no |
| <a name="input_image_cleaner_enabled"></a> [image\_cleaner\_enabled](#input\_image\_cleaner\_enabled) | Enable or disable the image cleaner in the AKS cluster to automatically remove unused container images. | `bool` | `true` | no |
| <a name="input_image_cleaner_interval_hours"></a> [image\_cleaner\_interval\_hours](#input\_image\_cleaner\_interval\_hours) | The interval in hours at which the image cleaner should run to clean up unused container images. | `number` | `72` | no |
| <a name="input_karpenter_crds_chart_version"></a> [karpenter\_crds\_chart\_version](#input\_karpenter\_crds\_chart\_version) | Version of the Karpenter crds Helm chart | `string` | `""` | no |
| <a name="input_karpenter_identity_name"></a> [karpenter\_identity\_name](#input\_karpenter\_identity\_name) | Name of the user-assigned managed identity. | `string` | `"karpentermsi"` | no |
| <a name="input_karpenter_namespace"></a> [karpenter\_namespace](#input\_karpenter\_namespace) | Namespace where Karpenter will be installed | `string` | `"kube-system"` | no |
| <a name="input_karpenter_roles"></a> [karpenter\_roles](#input\_karpenter\_roles) | List of built-in roles to assign to the Karpenter MSI | `list(string)` | <pre>[<br/>  "Virtual Machine Contributor",<br/>  "Network Contributor",<br/>  "Managed Identity Operator"<br/>]</pre> | no |
| <a name="input_karpenter_version"></a> [karpenter\_version](#input\_karpenter\_version) | n/a | `string` | `""` | no |
| <a name="input_key_vault_secrets_provider_enabled"></a> [key\_vault\_secrets\_provider\_enabled](#input\_key\_vault\_secrets\_provider\_enabled) | Enable the integration of the Azure Key Vault Secrets Provider to mount secrets into AKS pods as volumes. | `bool` | `true` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | AKS kubernetes version | `string` | `""` | no |
| <a name="input_location"></a> [location](#input\_location) | Azure Region | `string` | `""` | no |
| <a name="input_log_analytics_workspace_enabled"></a> [log\_analytics\_workspace\_enabled](#input\_log\_analytics\_workspace\_enabled) | Indicates whether a Log Analytics workspace should be linked to the AKS cluster for monitoring. | `bool` | `false` | no |
| <a name="input_net_profile_dns_service_ip"></a> [net\_profile\_dns\_service\_ip](#input\_net\_profile\_dns\_service\_ip) | The IP address within the service CIDR to use for the Kubernetes DNS service (kube-dns/CoreDNS). Must be within the net\_profile\_service\_cidr range. | `string` | `"10.100.0.10"` | no |
| <a name="input_net_profile_pod_cidr"></a> [net\_profile\_pod\_cidr](#input\_net\_profile\_pod\_cidr) | The CIDR block used for pod IP addresses in the AKS cluster. Required when using kubenet or overlay network plugin. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_net_profile_service_cidr"></a> [net\_profile\_service\_cidr](#input\_net\_profile\_service\_cidr) | The CIDR block used for Kubernetes service IPs in the AKS cluster. | `string` | `"10.0.0.0/16"` | no |
| <a name="input_network_ip_versions"></a> [network\_ip\_versions](#input\_network\_ip\_versions) | Specifies the IP version used in the AKS cluster. Allowed values are 'IPv4' or 'IPv6'. | `list(string)` | <pre>[<br/>  "IPv4"<br/>]</pre> | no |
| <a name="input_network_plugin"></a> [network\_plugin](#input\_network\_plugin) | Network plugin for AKS | `string` | `""` | no |
| <a name="input_network_plugin_mode"></a> [network\_plugin\_mode](#input\_network\_plugin\_mode) | Specifies the network plugin mode. 'overlay' is used with the Azure CNI Overlay plugin. | `string` | `"overlay"` | no |
| <a name="input_network_policy"></a> [network\_policy](#input\_network\_policy) | network policy to be used with Azure CNI | `string` | `""` | no |
| <a name="input_oidc_issuer_enabled"></a> [oidc\_issuer\_enabled](#input\_oidc\_issuer\_enabled) | Enable the OpenID Connect (OIDC) issuer URL, which is required for Kubernetes workload identity and federated identity with external systems. | `bool` | `true` | no |
| <a name="input_only_critical_addons_enabled"></a> [only\_critical\_addons\_enabled](#input\_only\_critical\_addons\_enabled) | Enable this setting to allow only critical addons to run on the system node pool, improving system isolation and performance. | `bool` | `true` | no |
| <a name="input_rbac_aad_azure_rbac_enabled"></a> [rbac\_aad\_azure\_rbac\_enabled](#input\_rbac\_aad\_azure\_rbac\_enabled) | Whether to enable Azure RBAC for Kubernetes authorization. If null, the provider default is used. | `bool` | `null` | no |
| <a name="input_rbac_aad_tenant_id"></a> [rbac\_aad\_tenant\_id](#input\_rbac\_aad\_tenant\_id) | The Azure AD tenant ID to use for Kubernetes RBAC integration. If null, the default tenant is used. | `string` | `null` | no |
| <a name="input_register_container_service"></a> [register\_container\_service](#input\_register\_container\_service) | Controls whether to register the Microsoft.ContainerService resource provider. | `bool` | `false` | no |
| <a name="input_role_based_access_control_enabled"></a> [role\_based\_access\_control\_enabled](#input\_role\_based\_access\_control\_enabled) | Enable Role-Based Access Control (RBAC) for the AKS cluster to manage permissions using Azure AD or Kubernetes native roles. | `bool` | `true` | no |
| <a name="input_subscription_id"></a> [subscription\_id](#input\_subscription\_id) | Azure Subscription ID | `string` | `""` | no |
| <a name="input_temporary_name_for_rotation"></a> [temporary\_name\_for\_rotation](#input\_temporary\_name\_for\_rotation) | Temporary name used for a node pool during node rotation or upgrade operations in the AKS cluster. This allows seamless replacement before removing the old node pool. | `string` | `"tempnodepool"` | no |
| <a name="input_vault_name"></a> [vault\_name](#input\_vault\_name) | name for key vault | `string` | `"kv-cluster"` | no |
| <a name="input_vnet_cidr"></a> [vnet\_cidr](#input\_vnet\_cidr) | CIDR block for the Virtual Network | `string` | `""` | no |
| <a name="input_workload_identity_enabled"></a> [workload\_identity\_enabled](#input\_workload\_identity\_enabled) | Enable Azure AD Workload Identity on the AKS cluster. This allows pods to use federated identity to access Azure resources securely. | `bool` | `true` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_aks_id"></a> [aks\_id](#output\_aks\_id) | The `azurerm_kubernetes_cluster`'s id. |
| <a name="output_aks_name"></a> [aks\_name](#output\_aks\_name) | The name of the Azure Kubernetes Cluster. |
| <a name="output_client_certificate"></a> [client\_certificate](#output\_client\_certificate) | The `client_certificate` in the `azurerm_kubernetes_cluster`'s `kube_config` block. |
| <a name="output_client_key"></a> [client\_key](#output\_client\_key) | The `client_key` in the `azurerm_kubernetes_cluster`'s `kube_config` block. |
| <a name="output_cluster_ca_certificate"></a> [cluster\_ca\_certificate](#output\_cluster\_ca\_certificate) | The `cluster_ca_certificate` in the `azurerm_kubernetes_cluster`'s `kube_config` block. |
| <a name="output_cluster_fqdn"></a> [cluster\_fqdn](#output\_cluster\_fqdn) | The FQDN of the Azure Kubernetes Managed Cluster. |
| <a name="output_cluster_identity"></a> [cluster\_identity](#output\_cluster\_identity) | The `azurerm_kubernetes_cluster`'s `identity` block. |
| <a name="output_cluster_portal_fqdn"></a> [cluster\_portal\_fqdn](#output\_cluster\_portal\_fqdn) | The FQDN for the Azure Portal resources when private link has been enabled, which is only resolvable inside the Virtual Network used by the Kubernetes Cluster. |
| <a name="output_cluster_private_fqdn"></a> [cluster\_private\_fqdn](#output\_cluster\_private\_fqdn) | The private FQDN for the Azure Kubernetes Cluster. |
| <a name="output_cluster_vnet_id"></a> [cluster\_vnet\_id](#output\_cluster\_vnet\_id) | AKS cluster vnet |
| <a name="output_host"></a> [host](#output\_host) | The `host` in the `azurerm_kubernetes_cluster`'s `kube_config` block. The Kubernetes cluster server host. |
| <a name="output_http_application_routing_zone_name"></a> [http\_application\_routing\_zone\_name](#output\_http\_application\_routing\_zone\_name) | The `azurerm_kubernetes_cluster`'s `http_application_routing_zone_name` argument. The Zone Name of the HTTP Application Routing. |
| <a name="output_ingress_application_gateway"></a> [ingress\_application\_gateway](#output\_ingress\_application\_gateway) | The `azurerm_kubernetes_cluster`'s `ingress_application_gateway` block. |
| <a name="output_ingress_application_gateway_enabled"></a> [ingress\_application\_gateway\_enabled](#output\_ingress\_application\_gateway\_enabled) | Has the `azurerm_kubernetes_cluster` turned on `ingress_application_gateway` block? |
| <a name="output_key_vault_secrets_provider"></a> [key\_vault\_secrets\_provider](#output\_key\_vault\_secrets\_provider) | The `azurerm_kubernetes_cluster`'s `key_vault_secrets_provider` block. |
| <a name="output_key_vault_secrets_provider_enabled"></a> [key\_vault\_secrets\_provider\_enabled](#output\_key\_vault\_secrets\_provider\_enabled) | Has the `azurerm_kubernetes_cluster` turned on `key_vault_secrets_provider` block? |
| <a name="output_kube_admin_config_raw"></a> [kube\_admin\_config\_raw](#output\_kube\_admin\_config\_raw) | The `azurerm_kubernetes_cluster`'s `kube_admin_config_raw` argument. Raw Kubernetes config for the admin account to be used by kubectl and other compatible tools. This is only available when Role Based Access Control with Azure Active Directory is enabled and local accounts enabled. |
| <a name="output_kube_config_raw"></a> [kube\_config\_raw](#output\_kube\_config\_raw) | The raw Kubernetes config for the cluster. |
| <a name="output_node_resource_group"></a> [node\_resource\_group](#output\_node\_resource\_group) | The auto-generated Resource Group which contains the resources for this Managed Kubernetes Cluster. |
| <a name="output_oidc_issuer_url"></a> [oidc\_issuer\_url](#output\_oidc\_issuer\_url) | The URL of the OIDC issuer for the Azure Kubernetes Cluster. |
| <a name="output_web_app_routing_identity"></a> [web\_app\_routing\_identity](#output\_web\_app\_routing\_identity) | The identity used for the web app routing. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
