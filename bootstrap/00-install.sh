#!/bin/bash
# =============================================================================
# Bootstrap Script - Infrastructure as Code
# =============================================================================
# This script installs all required components for the GitOps infrastructure
# Run this once on a fresh Kubernetes cluster
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}  Maria Guestbook - Infrastructure Bootstrap ${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""

# Check prerequisites
echo -e "${YELLOW}[1/7] Checking prerequisites...${NC}"

if ! command -v kubectl &> /dev/null; then
    echo -e "${RED}Error: kubectl not found. Please install kubectl first.${NC}"
    exit 1
fi

if ! kubectl cluster-info &> /dev/null; then
    echo -e "${RED}Error: Cannot connect to Kubernetes cluster.${NC}"
    echo "Please configure kubectl to connect to your cluster."
    exit 1
fi

echo -e "${GREEN}✓ kubectl configured and cluster accessible${NC}"
echo ""

# Create namespaces
echo -e "${YELLOW}[2/7] Creating namespaces...${NC}"
kubectl apply -f "$SCRIPT_DIR/cluster/namespaces.yaml"
echo -e "${GREEN}✓ Namespaces created${NC}"
echo ""

# Install ArgoCD namespace
echo -e "${YELLOW}[3/7] Creating ArgoCD namespace...${NC}"
kubectl apply -f "$SCRIPT_DIR/argocd/namespace.yaml"
echo -e "${GREEN}✓ ArgoCD namespace created${NC}"
echo ""

# Install ArgoCD
echo -e "${YELLOW}[4/7] Installing ArgoCD...${NC}"
echo "  Downloading and applying ArgoCD manifests..."
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
echo -e "${GREEN}✓ ArgoCD installed${NC}"
echo ""

# Wait for ArgoCD to be ready
echo -e "${YELLOW}[5/7] Waiting for ArgoCD to be ready...${NC}"
echo "  This may take 1-2 minutes..."
kubectl wait --for=condition=available --timeout=300s deployment/argocd-server -n argocd
echo -e "${GREEN}✓ ArgoCD is ready${NC}"
echo ""

# Apply ArgoCD configuration
echo -e "${YELLOW}[6/7] Applying ArgoCD configuration...${NC}"
kubectl apply -f "$SCRIPT_DIR/argocd/configmap.yaml"
kubectl apply -f "$SCRIPT_DIR/argocd/ingress.yaml"
kubectl apply -f "$SCRIPT_DIR/argocd/projects.yaml"
echo -e "${GREEN}✓ ArgoCD configured${NC}"
echo ""

# Apply RBAC and quotas
echo -e "${YELLOW}[7/7] Applying RBAC and resource quotas...${NC}"
kubectl apply -f "$SCRIPT_DIR/cluster/rbac.yaml"
kubectl apply -f "$SCRIPT_DIR/cluster/resource-quotas.yaml"
echo -e "${GREEN}✓ RBAC and quotas applied${NC}"
echo ""

# Get ArgoCD password
echo -e "${BLUE}=============================================${NC}"
echo -e "${GREEN}  Bootstrap Complete!${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""
echo -e "${YELLOW}ArgoCD Admin Credentials:${NC}"
echo -e "  Username: admin"
echo -n "  Password: "
kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" 2>/dev/null | base64 -d
echo ""
echo ""
echo -e "${YELLOW}Next Steps:${NC}"
echo "  1. Create secrets:    ./scripts/setup-secrets.sh"
echo "  2. Deploy apps:       kubectl apply -f argocd/app-of-apps.yaml"
echo "  3. Access ArgoCD:     https://argocd.cicd.cachefly.site"
echo "  4. Access Guestbook:  https://maria-guestbook.cicd.cachefly.site"
echo ""
echo -e "${YELLOW}Useful Commands:${NC}"
echo "  kubectl get pods -n argocd"
echo "  kubectl get pods -n maria-guestbook"
echo "  kubectl get applications -n argocd"
echo ""
