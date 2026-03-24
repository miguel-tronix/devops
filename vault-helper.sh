#!/bin/bash
# Vault Initialization and Unseal Helper

set -e

NAMESPACE="vault"
POD_NAME="vault-0"

echo "Checking Vault status..."
VAULT_STATUS=$(kubectl exec -n $NAMESPACE $POD_NAME -- vault status -format=json || true)

if [[ $VAULT_STATUS == *"initialized\": false"* ]]; then
  echo "Initializing Vault..."
  INIT_OUTPUT=$(kubectl exec -n $NAMESPACE $POD_NAME -- vault operator init -key-shares=1 -key-threshold=1 -format=json)
  echo "Vault initialized! SAVING KEYS TO vault-keys.json (DO NOT LOSE THIS!)"
  echo "$INIT_OUTPUT" > vault-keys.json
else
  echo "Vault already initialized."
fi

UNSEAL_KEY=$(cat vault-keys.json | jq -r '.unseal_keys_b64[0]')
ROOT_TOKEN=$(cat vault-keys.json | jq -r '.root_token')

echo "Unsealing Vault..."
kubectl exec -n $NAMESPACE $POD_NAME -- vault operator unseal "$UNSEAL_KEY"

echo "Vault is unsealed. Root token: $ROOT_TOKEN"

# SETUP KUBERNETES AUTH FOR ESO
echo "Setting up Kubernetes Auth Method..."
kubectl exec -n $NAMESPACE $POD_NAME -- vault login "$ROOT_TOKEN"
kubectl exec -n $NAMESPACE $POD_NAME -- vault auth enable kubernetes || true
kubectl exec -n $NAMESPACE $POD_NAME -- vault write auth/kubernetes/config \
    kubernetes_host="https://kubernetes.default.svc:443"

# SETUP POLICY AND ROLE FOR ESO
echo "Creating policy for ESO..."
kubectl exec -n $NAMESPACE $POD_NAME -- vault policy write external-secrets - <<EOF
path "secret/data/*" {
  capabilities = ["read"]
}
EOF

echo "Creating role for ESO..."
kubectl exec -n $NAMESPACE $POD_NAME -- vault write auth/kubernetes/role/external-secrets \
    bound_service_account_names="external-secrets" \
    bound_service_account_namespaces="external-secrets" \
    policies="external-secrets" \
    ttl=24h

# ENABLE KV2 ENGINE
echo "Enabling KV2 engine..."
kubectl exec -n $NAMESPACE $POD_NAME -- vault secrets enable -path=secret kv-v2 || true

echo "Setup complete! You can now put secrets into Vault at 'secret/gitea/db' and 'secret/gitea/redis'."
