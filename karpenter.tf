resource "null_resource" "karpenter_config" {

  provisioner "local-exec" {
    command = "${path.root}/bin/karpenter.sh"
    environment = {
    }
  }
  triggers = {
    checksum = filesha256("${path.module}/bin/karpenter.sh")
  }
}

resource "azurerm_user_assigned_identity" "karpenter_msi" {
  name                = var.karpenter_identity_name
  location            = var.location
  resource_group_name = azurerm_resource_group.aks_rg.name
}

resource "azurerm_role_assignment" "karpenter_roles" {
  for_each             = toset(var.karpenter_roles)
  scope                = azurerm_resource_group.aks_rg.id
  role_definition_name = each.key
  principal_id         = azurerm_user_assigned_identity.karpenter_msi.principal_id
}


resource "helm_release" "karpenter_crds" {
  name       = "karpenter-crds"
  repository = "https://charts.karpenter.sh"
  chart      = "karpenter-crds"
  version    = var.karpenter_crds_chart_version
  namespace  = var.karpenter_namespace
}

resource "helm_release" "karpenter" {
  name             = "karpenter"
  namespace        = var.karpenter_namespace
  create_namespace = true

  chart   = "oci://mcr.microsoft.com/aks/karpenter/karpenter"
  version = var.karpenter_version

  values = [file("${path.module}/templates/karpenter/karpenter-values.yaml")]

}