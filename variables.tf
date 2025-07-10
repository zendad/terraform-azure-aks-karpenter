variable "subscription_id" {
  description = "Azure Subscription ID"
  type        = string
  default     = ""
}

variable "location" {
  description = "Azure Region"
  type        = string
  default     = ""
}

variable "environment" {
  description = "Deployment environment"
  type        = string
  default     = ""
}

variable "kubernetes_version" {
  description = "AKS kubernetes version"
  type        = string
  default     = ""
}

variable "vnet_cidr" {
  description = "CIDR block for the Virtual Network"
  type        = string
  default     = ""
}

variable "availability_zones" {
  description = "List of availability zones to use"
  type        = list(string)
  default     = []
}

variable "default_tags" {
  description = "Default tags for all resources"
  type        = map(string)
  default     = {}
}

variable "network_plugin" {
  description = "Network plugin for AKS"
  type        = string
  default     = ""
}

variable "network_policy" {
  description = "network policy to be used with Azure CNI"
  type        = string
  default     = ""
}

variable "api_server_authorized_ip_ranges" {
  description = "Set of authorized IP ranges for the API server"
  type        = set(string)
  default     = null
}

variable "vault_name" {
  description = "name for key vault"
  type        = string
  default     = "kv-cluster"
}


variable "account_tier" {
  description = "The performance tier of the storage account (Standard or Premium)"
  type        = string
  default     = "Standard"
}

variable "account_replication_type" {
  description = "The replication type of the storage account (e.g., LRS, GRS, ZRS)"
  type        = string
  default     = "LRS"
}

variable "container_access_type" {
  description = "The access level of the storage container (private, blob, or container)"
  type        = string
  default     = "private"

  validation {
    condition     = contains(["private", "blob", "container"], var.container_access_type)
    error_message = "container_access_type must be one of: private, blob, or container"
  }
}

variable "role_based_access_control_enabled" {
  type        = bool
  default     = true
  description = "Enable Role-Based Access Control (RBAC) for the AKS cluster to manage permissions using Azure AD or Kubernetes native roles."
}

variable "oidc_issuer_enabled" {
  type        = bool
  default     = true
  description = "Enable the OpenID Connect (OIDC) issuer URL, which is required for Kubernetes workload identity and federated identity with external systems."
}

variable "enable_auto_scaling" {
  type        = bool
  default     = true
  description = "Enable cluster autoscaler for the AKS node pool to automatically adjust the number of nodes based on workload demand."
}

variable "temporary_name_for_rotation" {
  type        = string
  default     = "tempnodepool"
  description = "Temporary name used for a node pool during node rotation or upgrade operations in the AKS cluster. This allows seamless replacement before removing the old node pool."
}

variable "agents_count" {
  type        = number
  default     = null
  description = "Specifies the number of agent nodes to provision. If null and autoscaling is enabled, min and max counts are used."
}

variable "agents_min_count" {
  type        = number
  default     = 1
  description = "The minimum number of agent nodes for the node pool when autoscaling is enabled."
}

variable "agents_max_count" {
  type        = number
  default     = 3
  description = "The maximum number of agent nodes for the node pool when autoscaling is enabled."
}

variable "agents_size" {
  type        = string
  default     = "Standard_D2s_v3"
  description = "The VM size to use for the agent node pool in the AKS cluster."
}

variable "log_analytics_workspace_enabled" {
  type        = bool
  default     = false
  description = "Indicates whether a Log Analytics workspace should be linked to the AKS cluster for monitoring."
}

variable "image_cleaner_enabled" {
  type        = bool
  default     = true
  description = "Enable or disable the image cleaner in the AKS cluster to automatically remove unused container images."
}

variable "image_cleaner_interval_hours" {
  type        = number
  default     = 72
  description = "The interval in hours at which the image cleaner should run to clean up unused container images."
}

variable "key_vault_secrets_provider_enabled" {
  type        = bool
  default     = true
  description = "Enable the integration of the Azure Key Vault Secrets Provider to mount secrets into AKS pods as volumes."
}

variable "agents_pool_name" {
  type        = string
  default     = "platformpool"
  description = "The name assigned to the default AKS agent node pool. This name must be unique within the AKS cluster and 3–12 characters long."
}

variable "agents_type" {
  type        = string
  default     = "VirtualMachineScaleSets"
  description = "Specifies the type of agent pool to use for the AKS cluster. Supported values are 'VirtualMachineScaleSets' (VMSS) and 'AvailabilitySet' (deprecated for new clusters)."
}

variable "agents_labels" {
  type        = map(string)
  default     = {}
  description = "A map of Kubernetes labels to apply to nodes in the default AKS node pool. Changing this value forces the node pool to be recreated."
}

variable "automatic_channel_upgrade" {
  type        = string
  default     = "patch"
  description = <<EOT
The automatic upgrade channel to use for the AKS cluster. Determines how the cluster is updated with newer Kubernetes versions.
Allowed values:
  - "patch"       → Only automatic patch updates within the same minor version.
  - "stable"      → Recommended channel for general workloads. Upgrades through stable minor versions.
  - "rapid"       → For testing the latest versions quickly.
  - "node-image"  → Only the node OS and container runtime get updated, Kubernetes version stays the same.
  - "none"        → Disables automatic upgrades. Manual upgrades are required.
EOT
}

variable "ebpf_data_plane" {
  type        = string
  default     = "none"
  description = <<EOT
Specifies the eBPF data plane implementation for the AKS cluster.
Allowed values:
  - "none"     : Disable eBPF data plane (default kube-proxy)
  - "cilium"   : Enable Cilium as the eBPF data plane
EOT
}

variable "identity_type" {
  type        = string
  default     = "SystemAssigned"
  description = "Specifies the type of managed identity used for the AKS cluster. Allowed values are 'SystemAssigned' or 'UserAssigned'."
}

variable "net_profile_pod_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block used for pod IP addresses in the AKS cluster. Required when using kubenet or overlay network plugin."
}

variable "net_profile_service_cidr" {
  type        = string
  default     = "10.0.0.0/16"
  description = "The CIDR block used for Kubernetes service IPs in the AKS cluster."
}

variable "network_ip_versions" {
  type        = list(string)
  default     = ["IPv4"]
  description = "Specifies the IP version used in the AKS cluster. Allowed values are 'IPv4' or 'IPv6'."
}

variable "network_plugin_mode" {
  type        = string
  default     = "overlay"
  description = "Specifies the network plugin mode. 'overlay' is used with the Azure CNI Overlay plugin."
}

variable "only_critical_addons_enabled" {
  type        = bool
  default     = true
  description = "Enable this setting to allow only critical addons to run on the system node pool, improving system isolation and performance."
}

variable "rbac_aad_tenant_id" {
  type        = string
  default     = null
  description = "The Azure AD tenant ID to use for Kubernetes RBAC integration. If null, the default tenant is used."
}

variable "rbac_aad_azure_rbac_enabled" {
  type        = bool
  default     = null
  description = "Whether to enable Azure RBAC for Kubernetes authorization. If null, the provider default is used."
}

variable "net_profile_dns_service_ip" {
  type        = string
  default     = "10.100.0.10"
  description = "The IP address within the service CIDR to use for the Kubernetes DNS service (kube-dns/CoreDNS). Must be within the net_profile_service_cidr range."
}

variable "agents_availability_zones" {
  type        = list(string)
  default     = null
  description = "List of Availability Zones for the AKS agent pool. Zones must be supported in the selected region and for the chosen VM size. Leave empty to disable zonal distribution."
}

variable "workload_identity_enabled" {
  description = "Enable Azure AD Workload Identity on the AKS cluster. This allows pods to use federated identity to access Azure resources securely."
  type        = bool
  default     = true
}

variable "karpenter_identity_name" {
  type        = string
  default     = "karpentermsi"
  description = "Name of the user-assigned managed identity."
}

variable "register_container_service" {
  description = "Controls whether to register the Microsoft.ContainerService resource provider."
  type        = bool
  default     = false
}

variable "karpenter_roles" {
  description = "List of built-in roles to assign to the Karpenter MSI"
  type        = list(string)
  default = [
    "Virtual Machine Contributor",
    "Network Contributor",
    "Managed Identity Operator"
  ]
}

variable "karpenter_namespace" {
  description = "Namespace where Karpenter will be installed"
  type        = string
  default     = "kube-system"
}

variable "karpenter_crds_chart_version" {
  description = "Version of the Karpenter crds Helm chart"
  type        = string
  default     = ""
}

variable "karpenter_version" {
  type    = string
  default = ""
}
