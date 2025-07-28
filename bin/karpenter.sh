#!/usr/bin/env bash
set -euo pipefail
# This script interrogates the AKS cluster and Azure resources to generate
# the karpenter-values.yaml file using the karpenter.yaml.tpl file as a template.

if [ "$#" -ne 6 ]; then
  echo "Usage: $0 <cluster-name> <resource-group> <karpenter-service-account-name> <karpenter-user-assigned-identity-name> <karpenter-dir> <karpenter-version>"
  exit 1
fi

CLUSTER_NAME="$1"
AZURE_RESOURCE_GROUP="$2"
KARPENTER_SERVICE_ACCOUNT_NAME="$3"
AZURE_KARPENTER_USER_ASSIGNED_IDENTITY_NAME="$4"
KARPENTER_DIR="$5"
KARPENTER_VERSION="$6"

echo "Generating karpenter-values.yaml for cluster: $CLUSTER_NAME"

# Extract cluster info
AKS_JSON=$(az aks show --name "$CLUSTER_NAME" --resource-group "$AZURE_RESOURCE_GROUP" -o json)
TOKEN_SECRET_NAME=$(kubectl get -n kube-system secrets --field-selector=type=bootstrap.kubernetes.io/token -o jsonpath='{.items[0].metadata.name}')
TOKEN_ID=$(kubectl get -n kube-system secret "$TOKEN_SECRET_NAME" -o jsonpath='{.data.token-id}' | base64 -d)
TOKEN_SECRET=$(kubectl get -n kube-system secret "$TOKEN_SECRET_NAME" -o jsonpath='{.data.token-secret}' | base64 -d)
BOOTSTRAP_TOKEN="$TOKEN_ID.$TOKEN_SECRET"
SSH_PUBLIC_KEY="$(cat ~/.ssh/id_rsa.pub) azureuser"

# Get VNET JSON
get_vnet_json() {
  local resource_group="$1"
  local aks_json="$2"
  local vnet_json

  vnet_json=$(az network vnet list --resource-group "$resource_group" | jq -r ".[0]")
  if [[ -z "$vnet_json" || "$vnet_json" == "null" ]]; then
    local subnet_id
    subnet_id=$(jq -r ".agentPoolProfiles[0].vnetSubnetId" <<< "$aks_json")
    local vnet_id
    vnet_id=$(echo "$subnet_id" | sed 's|/subnets/[^/]*$||')
    vnet_json=$(az network vnet show --ids "$vnet_id")
  fi
  echo "$vnet_json"
}

VNET_JSON=$(get_vnet_json "${NODEPOOL_RG}" "$AKS_JSON")
VNET_GUID=$(jq -r ".resourceGuid // empty" <<< "$VNET_JSON")
NODE_IDENTITIES=$(jq -r ".identityProfile.kubeletidentity.resourceId" <<< "$AKS_JSON")

# Export values
export CLUSTER_NAME \
  AZURE_LOCATION="${LOCATION}" \
  AZURE_RESOURCE_GROUP="${AZURE_RESOURCE_GROUP}" \
  AZURE_RESOURCE_GROUP_MC="${NODEPOOL_RG}" \
  KARPENTER_SERVICE_ACCOUNT_NAME \
  CLUSTER_ENDPOINT="https://${CLUSTER_FQDN}" \
  BOOTSTRAP_TOKEN \
  SSH_PUBLIC_KEY \
  VNET_SUBNET_ID="${SUBNET_ID}" \
  KARPENTER_USER_ASSIGNED_CLIENT_ID="${CLIENT_ID}" \
  NODE_IDENTITIES \
  AZURE_SUBSCRIPTION_ID="${SUBSCRIPTION_ID}" \
  NETWORK_PLUGIN \
  NETWORK_PLUGIN_MODE \
  NETWORK_POLICY \
  LOG_LEVEL="${KARPENTER_LOG_LEVEL:-info}" \
  VNET_GUID \
  KARPENTER_RESOURCE_REQUEST_MEMORY="${REQUEST_MEM}" \
  KARPENTER_RESOURCE_REQUEST_CPU="${REQUEST_CPU}" \
  KARPENTER_RESOURCE_LIMIT_MEMORY="${LIMIT_MEM}" \


TEMPLATE_FILE="${KARPENTER_DIR}/karpenter.yaml.tpl"
OUTPUT_FILE="${KARPENTER_DIR}/karpenter-values.yaml"

# Fetch template if missing
if [ ! -f "$TEMPLATE_FILE" ]; then
  mkdir -p "$KARPENTER_DIR"
  curl -sLo "$TEMPLATE_FILE" "https://raw.githubusercontent.com/Azure/karpenter-provider-azure/refs/tags/v${KARPENTER_VERSION}/karpenter-values-template.yaml"
fi

# Render the final values file
yq '(.. | select(tag == "!!str")) |= envsubst(nu)' "$TEMPLATE_FILE" > "$OUTPUT_FILE"
