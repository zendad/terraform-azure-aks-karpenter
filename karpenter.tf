# karpenter bootstrapping
resource "azurerm_user_assigned_identity" "karpenter" {
  name                = var.karpenter_identity_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.default_nodepool.name
}

resource "azurerm_federated_identity_credential" "karpenter_fic" {
  name                = var.karpenter_identity_name
  resource_group_name = data.azurerm_resource_group.default_nodepool.name
  parent_id           = azurerm_user_assigned_identity.karpenter.id

  issuer   = module.aks.oidc_issuer_url
  subject  = "system:serviceaccount:${var.karpenter_namespace}:${var.karpenter_service_account_name}"
  audience = ["api://AzureADTokenExchange"]
}


resource "azurerm_role_assignment" "karpenter_roles" {
  for_each             = toset(var.karpenter_roles)
  scope                = data.azurerm_resource_group.default_nodepool.id
  role_definition_name = each.key
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}

resource "azurerm_role_assignment" "karpenter_subnet_roles" {
  for_each             = toset(local.private_subnet_id_list)
  scope                = each.value
  role_definition_name = var.karpenter_subnet_role_definition
  principal_id         = azurerm_user_assigned_identity.karpenter.principal_id
}

resource "null_resource" "karpenter" {
  provisioner "local-exec" {
    command = <<EOT
      set -e
      export KUBECONFIG=$(mktemp)

      cat > "$KUBECONFIG" <<EOF
apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${module.aks.admin_cluster_ca_certificate}
    server: ${module.aks.admin_host}
  name: aks
contexts:
- context:
    cluster: aks
    user: aks-user
  name: aks-context
current-context: aks-context
kind: Config
preferences: {}
users:
- name: aks-user
  user:
    client-certificate-data: ${module.aks.admin_client_certificate}
    client-key-data: ${module.aks.admin_client_key}
EOF

      export KARPENTER_LOG_LEVEL="${local.karpenter_log_level}"
      export LOCATION="${var.location}"
      export NODEPOOL_RG="${local.nodepool_resource_group_name}"
      export SUBSCRIPTION_ID="${data.azurerm_client_config.current.subscription_id}"
      export CLUSTER_FQDN="${module.aks.cluster_fqdn}"
      export SUBNET_ID="${local.default_nodepool_subnet_id}"
      export NETWORK_PLUGIN="${var.network_plugin}"
      export NETWORK_PLUGIN_MODE="${var.network_plugin_mode}"
      export NETWORK_POLICY="${var.network_policy}"
      export CLIENT_ID="${azurerm_user_assigned_identity.karpenter.client_id}"
      export REQUEST_MEM="${var.karpenter_resources.request_memory}"
      export REQUEST_CPU="${var.karpenter_resources.request_cpu}"
      export LIMIT_MEM="${var.karpenter_resources.limit_memory}"

      chmod +x ${path.module}/bin/karpenter.sh

      ${path.module}/bin/karpenter.sh \
        "${module.aks.aks_name}" \
        "${azurerm_resource_group.aks_rg.name}" \
        "${var.karpenter_service_account_name}" \
        "${var.karpenter_identity_name}" \
        "${path.module}/templates/karpenter" \
        "${var.karpenter_version}"

      helm upgrade --install karpenter oci://mcr.microsoft.com/aks/karpenter/karpenter \
        --version "${var.karpenter_version}" \
        --namespace "${var.karpenter_namespace}" \
        --values "${path.module}/templates/karpenter/karpenter-values.yaml"
    EOT

    interpreter = ["/bin/bash", "-c"]
  }

  triggers = {
    script_sha = filesha256("${path.module}/bin/karpenter.sh")
    template_sha = filesha256("${path.module}/templates/karpenter/karpenter.yaml.tpl")
  }
  
  depends_on = [module.aks]
}


resource "helm_release" "karpenter_nodepools" {
  depends_on = [null_resource.karpenter]
  name       = "karpenter-azure-nodepools"
  chart      = "${path.module}/templates/karpenter-nodepools/karpenter-azure-nodepools"
  namespace  = "kube-system"
}
