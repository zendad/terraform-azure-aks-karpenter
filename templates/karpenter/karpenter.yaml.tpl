
replicas: 2
controller:
  env:
    - name: DISABLE_LEADER_ELECTION
      value: "true"
    - name: CLUSTER_NAME
      value: ${CLUSTER_NAME}
    - name: CLUSTER_ENDPOINT
      value: ${CLUSTER_ENDPOINT}
    - name: KUBELET_BOOTSTRAP_TOKEN
      value: ${BOOTSTRAP_TOKEN}
    - name: SSH_PUBLIC_KEY
      value: "${SSH_PUBLIC_KEY}"
    - name: NETWORK_PLUGIN
      value: ${NETWORK_PLUGIN}
    - name: NETWORK_PLUGIN_MODE
      value: ${NETWORK_PLUGIN_MODE}
    - name: NETWORK_POLICY
      value: ${NETWORK_POLICY}
    - name: VNET_SUBNET_ID
      value: ${VNET_SUBNET_ID}
    - name: VNET_GUID
      value: ${VNET_GUID}
    - name: NODE_IDENTITIES
      value: ${NODE_IDENTITIES}

    # Azure client settings
    - name: ARM_SUBSCRIPTION_ID
      value: ${AZURE_SUBSCRIPTION_ID}
    - name: LOCATION
      value: ${AZURE_LOCATION}
    - name: KUBELET_IDENTITY_CLIENT_ID
      value: ""
    - name: AZURE_NODE_RESOURCE_GROUP
      value: ${AZURE_RESOURCE_GROUP_MC}

    # managed karpenter settings
    - name: USE_SIG
      value: "false"
    - name: SIG_ACCESS_TOKEN_SERVER_URL
      value: ""
    - name: SIG_ACCESS_TOKEN_SCOPE
      value: ""
    - name: SIG_SUBSCRIPTION_ID
      value: ""
  resources:
    requests:
      memory: ${KARPENTER_RESOURCE_REQUEST_MEMORY}
      cpu: ${KARPENTER_RESOURCE_REQUEST_CPU}
    limits:
      memory: ${KARPENTER_RESOURCE_LIMIT_MEMORY}
serviceAccount:
  name: ${KARPENTER_SERVICE_ACCOUNT_NAME}
  annotations:
    azure.workload.identity/client-id: ${KARPENTER_USER_ASSIGNED_CLIENT_ID}
podLabels:
  azure.workload.identity/use: "true"
logLevel: ${LOG_LEVEL}

settings:
  featureGates:
    spotToSpotConsolidation: true

affinity:
  nodeAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      nodeSelectorTerms:
        - matchExpressions:
            - key: karpenter.sh/nodepool
              operator: DoesNotExist
  podAntiAffinity:
    requiredDuringSchedulingIgnoredDuringExecution:
      - topologyKey: "kubernetes.io/hostname"

tolerations:
  - key: CriticalAddonsOnly
    operator: Exists