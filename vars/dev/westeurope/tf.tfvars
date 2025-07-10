subscription_id = ""
location        = "westeurope"
environment     = "dev"

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

agents_labels = {
  environment = "Dev"
  owner       = "Infrastructure"
  contact     = "CorePlatform"
  project     = "CorePlatform"
  costcenter  = "containerplatform"
}

account_tier               = "Standard"
account_replication_type   = "GRS"
container_access_type      = "private"
ebpf_data_plane            = "cilium"
net_profile_pod_cidr       = "172.16.0.0/16"
net_profile_service_cidr   = "10.100.0.0/16"
net_profile_dns_service_ip = "10.100.0.10"
kubernetes_version         = "1.32"
vnet_cidr                  = "10.0.0.0/16"
availability_zones         = ["1", "2", "3"]
network_plugin             = "azure"
network_policy             = "cilium"

karpenter_crds_chart_version = "0.1.0"
karpenter_namespace = "karpenter"
karpenter_version = "0.29.2"

node_pools = {
  tooling_nodes = {
    name                = "tooling"
    vm_size             = "Standard_D2s_v3"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 6
    max_pods            = 150
    mode                = "System"
    os_type             = "Linux"
    os_disk_size_gb     = 50
    priority            = "Regular"
    node_taints         = ["CriticalAddonsOnly=true:NoSchedule"]
    node_labels = {
      "role" = "tooling"
      "apps" = "tooling"
    }
  }
}