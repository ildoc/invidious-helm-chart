#!/bin/bash
# Script to create Kubernetes secrets for Invidious production deployment
#
# Usage: ./create-secrets.sh
#
# This script generates secure random keys and creates Kubernetes secrets
# required for production Invidious deployment.

set -euo pipefail

NAMESPACE="${NAMESPACE:-default}"
SECRET_NAME="${SECRET_NAME:-invidious-secrets}"

echo "Creating Kubernetes secrets for Invidious..."
echo "Namespace: $NAMESPACE"
echo "Secret name: $SECRET_NAME"

# Generate secure random keys
echo "Generating secure keys..."
COMPANION_KEY=$(openssl rand -base64 32)
HMAC_KEY=$(openssl rand -base64 32) 
POSTGRES_PASSWORD=$(openssl rand -base64 32)

# Create the secret
kubectl create secret generic "$SECRET_NAME" \
  --namespace="$NAMESPACE" \
  --from-literal=invidious-companion-key="$COMPANION_KEY" \
  --from-literal=hmac-key="$HMAC_KEY" \
  --from-literal=postgresql-password="$POSTGRES_PASSWORD" \
  --dry-run=client \
  --output=yaml > "$SECRET_NAME.yaml"

echo "Secret definition saved to: $SECRET_NAME.yaml"
echo ""
echo "To apply the secret to your cluster:"
echo "  kubectl apply -f $SECRET_NAME.yaml"
echo ""
echo "To install Invidious with the secret:"
echo "  helm install invidious invidious/invidious \\"
echo "    --set existingSecret=$SECRET_NAME \\"
echo "    --set postgresql.auth.existingSecret=$SECRET_NAME"
echo ""
echo "⚠️  IMPORTANT: Store the generated keys securely!"
echo "   The keys are saved in $SECRET_NAME.yaml"
echo "   Consider using a secret management system like:"
echo "   - External Secrets Operator"
echo "   - Sealed Secrets"
echo "   - HashiCorp Vault"
