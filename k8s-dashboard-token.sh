#!/bin/bash

# Script to generate a new token for Kubernetes Dashboard
# This script creates a token for the admin-user service account in kubernetes-dashboard namespace

set -e

NAMESPACE="kubernetes-dashboard"
SERVICE_ACCOUNT="admin-user"
TOKEN_FILE="k8-token.tkn"

echo "🔑 Generating new Kubernetes Dashboard token..."
echo "================================================"

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ Error: kubectl is not installed or not in PATH"
    exit 1
fi

# Check if the namespace exists
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo "❌ Error: Namespace '$NAMESPACE' does not exist"
    echo "   Please create the dashboard first using k8s-dashboard-create.sh"
    exit 1
fi

# Check if the service account exists
if ! kubectl get serviceaccount "$SERVICE_ACCOUNT" -n "$NAMESPACE" &> /dev/null; then
    echo "⚠️  Service account '$SERVICE_ACCOUNT' not found. Creating it..."
    kubectl create serviceaccount "$SERVICE_ACCOUNT" -n "$NAMESPACE"
    
    # Create ClusterRoleBinding for admin access
    echo "🔐 Creating cluster role binding..."
    kubectl create clusterrolebinding "${SERVICE_ACCOUNT}-binding" \
        --clusterrole=cluster-admin \
        --serviceaccount="$NAMESPACE:$SERVICE_ACCOUNT" 2>/dev/null || \
        echo "   (Binding may already exist, continuing...)"
fi

# Generate token (works with Kubernetes 1.24+)
echo "📝 Creating token..."
TOKEN=$(kubectl create token "$SERVICE_ACCOUNT" -n "$NAMESPACE" --duration=87600h)

if [ -z "$TOKEN" ]; then
    echo "❌ Error: Failed to generate token"
    exit 1
fi

# Save token to file
echo "$TOKEN" > "$TOKEN_FILE"
echo "✅ Token generated successfully!"
echo ""
echo "📄 Token saved to: $TOKEN_FILE"
echo ""

# Try to copy to clipboard if xclip is available
if command -v xclip &> /dev/null; then
    echo "$TOKEN" | xclip -selection clipboard
    echo "📋 Token copied to clipboard!"
elif command -v xsel &> /dev/null; then
    echo "$TOKEN" | xsel --clipboard
    echo "📋 Token copied to clipboard!"
else
    echo "ℹ️  Install 'xclip' or 'xsel' to auto-copy token to clipboard"
fi

echo ""
echo "🔑 Your token:"
echo "================================================"
echo "$TOKEN"
echo "================================================"
echo ""
echo "💡 Use this token to log in to the Kubernetes Dashboard"
echo "   Dashboard URL: http://localhost:14333 (if port-forward is running)"
echo ""
