# environment vars
subscription_id = ""
location        = "westeurope"
environment     = "dev"

# tags
default_tags = {
  environment = "Dev"
  owner       = "Infrastructure"
  contact     = "CorePlatform"
  project     = "CorePlatform"
  costcenter  = "containerplatform"
  application = "platform-services"
  managedby   = "Terraform"
  gitlab      = ""
}

# agent node labels
agents_labels = {
  environment = "Dev"
  owner       = "Infrastructure"
  contact     = "CorePlatform"
  project     = "CorePlatform"
  costcenter  = "containerplatform"
}

# cluster variables
account_tier                       = "Standard"
account_replication_type           = "GRS"
container_access_type              = "private"
ebpf_data_plane                    = "cilium"
net_profile_pod_cidr               = "172.13.0.0/16"
net_profile_service_cidr           = "172.15.0.0/16"
net_profile_dns_service_ip         = "172.15.0.10"
kubernetes_version                 = "1.32"
vnet_cidr                          = "172.17.0.0/16"
network_plugin                     = "azure"
network_policy                     = "cilium"
enable_auto_scaling                = false
agents_count                       = 1
agents_min_count                   = 1
agents_max_count                   = 1
os_disk_size_gb                    = 60
key_vault_secrets_provider_enabled = true
kms_enabled                        = true
kms_key_vault_network_access       = "public"
private_cluster_enabled            = false
secret_rotation_enabled            = true
secret_rotation_interval           = "3600m"
key_vault_ip_rules                 = ["185.209.237.248"]

# karpenter
karpenter_crds_chart_version = "0.7.5"
karpenter_namespace          = "kube-system"
karpenter_version            = "1.5.4"
bootstrap_token_secret_name  = "dereck"