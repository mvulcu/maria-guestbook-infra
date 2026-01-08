#!/bin/bash
# =============================================================================
# Setup Secrets - Infrastructure as Code
# =============================================================================
# ⚠️  DEPRECATED: This script is kept for reference only!
#
# Secrets are now managed via SealedSecrets in Git:
#   - helm/guestbook/templates/secrets/sealed-secrets.yaml
#   - helm/guestbook/values.yaml (sealedSecrets section)
#
# To rotate secrets:
#   1. Create new secret: kubectl create secret generic ...
#   2. Seal it: kubeseal --format yaml < secret.yaml > sealed.yaml
#   3. Update values.yaml with new encryptedData
#   4. Commit and push - ArgoCD will apply automatically
#
# This script is kept for emergency manual secret creation only.
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

NAMESPACE="maria-guestbook"

echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}  Setup Secrets for Maria Guestbook         ${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""

# Check if namespace exists
if ! kubectl get namespace "$NAMESPACE" &> /dev/null; then
    echo -e "${RED}Error: Namespace '$NAMESPACE' does not exist.${NC}"
    echo "Run bootstrap first: ./bootstrap/00-install.sh"
    exit 1
fi

# -----------------------------------------------------------------------------
# Redis Secret
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[1/2] Creating Redis secret...${NC}"

if kubectl get secret maria-redis-secret -n "$NAMESPACE" &> /dev/null; then
    echo -e "${GREEN}✓ Redis secret already exists${NC}"
else
    # Generate random password or use provided
    if [ -z "$REDIS_PASSWORD" ]; then
        REDIS_PASSWORD=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 32)
        echo "  Generated random password"
    fi

    kubectl create secret generic maria-redis-secret \
        --from-literal=password="$REDIS_PASSWORD" \
        -n "$NAMESPACE"

    echo -e "${GREEN}✓ Redis secret created${NC}"
    echo -e "  Password: ${YELLOW}$REDIS_PASSWORD${NC}"
    echo -e "  ${RED}Save this password! It won't be shown again.${NC}"
fi
echo ""

# -----------------------------------------------------------------------------
# GHCR Pull Secret
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[2/2] Creating GHCR pull secret...${NC}"

if kubectl get secret ghcr-secret -n "$NAMESPACE" &> /dev/null; then
    echo -e "${GREEN}✓ GHCR secret already exists${NC}"
else
    echo -e "${YELLOW}Enter your GitHub credentials for GHCR:${NC}"
    read -p "  GitHub Username: " GITHUB_USER
    read -sp "  GitHub Personal Access Token (with read:packages): " GITHUB_TOKEN
    echo ""

    kubectl create secret docker-registry ghcr-secret \
        --docker-server=ghcr.io \
        --docker-username="$GITHUB_USER" \
        --docker-password="$GITHUB_TOKEN" \
        -n "$NAMESPACE"

    echo -e "${GREEN}✓ GHCR secret created${NC}"
    echo -e "${GREEN}✓ GHCR secret created${NC}"
fi
echo ""

# -----------------------------------------------------------------------------
# Postgres Secret
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[3/3] Creating Postgres secret...${NC}"

if kubectl get secret maria-postgres-secret -n "$NAMESPACE" &> /dev/null; then
    echo -e "${GREEN}✓ Postgres secret already exists${NC}"
else
    # Generate random password or use provided
    if [ -z "$DB_PASSWORD" ]; then
        DB_PASSWORD=$(openssl rand -base64 24 | tr -dc 'a-zA-Z0-9' | head -c 32)
        echo "  Generated random password"
    fi

    kubectl create secret generic maria-postgres-secret \
        --from-literal=password="$DB_PASSWORD" \
        -n "$NAMESPACE"

    echo -e "${GREEN}✓ Postgres secret created${NC}"
    echo -e "  Password: ${YELLOW}$DB_PASSWORD${NC}"
    echo -e "  ${RED}Save this password! It won't be shown again.${NC}"
fi
echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo -e "${BLUE}=============================================${NC}"
echo -e "${GREEN}  Secrets Setup Complete!${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""
echo -e "${YELLOW}Created secrets:${NC}"
kubectl get secrets -n "$NAMESPACE"
echo ""
echo -e "${YELLOW}Next step:${NC}"
echo "  kubectl apply -f argocd/app-of-apps.yaml"
echo ""
