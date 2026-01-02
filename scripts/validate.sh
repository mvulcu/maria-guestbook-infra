#!/bin/bash
# =============================================================================
# Validate Manifests - Infrastructure as Code
# =============================================================================
# Validates all YAML manifests and Helm charts
# =============================================================================

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(dirname "$SCRIPT_DIR")"

echo -e "${BLUE}=============================================${NC}"
echo -e "${BLUE}  Validate Infrastructure Manifests         ${NC}"
echo -e "${BLUE}=============================================${NC}"
echo ""

ERRORS=0

# -----------------------------------------------------------------------------
# Validate YAML syntax
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[1/3] Checking YAML syntax...${NC}"

for file in $(find "$ROOT_DIR" -name "*.yaml" -o -name "*.yml" | grep -v node_modules | grep -v templates); do
    if ! python3 -c "import yaml; yaml.safe_load(open('$file'))" 2>/dev/null; then
        echo -e "${RED}  ✗ Invalid YAML: $file${NC}"
        ((ERRORS++))
    fi
done

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✓ All YAML files are valid${NC}"
fi
echo ""

# -----------------------------------------------------------------------------
# Validate Helm chart
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[2/3] Validating Helm chart...${NC}"

if command -v helm &> /dev/null; then
    if helm lint "$ROOT_DIR/helm/guestbook" --quiet; then
        echo -e "${GREEN}✓ Helm chart is valid${NC}"
    else
        echo -e "${RED}✗ Helm chart has issues${NC}"
        ((ERRORS++))
    fi
    
    # Try template rendering
    echo "  Rendering templates..."
    if helm template test "$ROOT_DIR/helm/guestbook" > /dev/null 2>&1; then
        echo -e "${GREEN}✓ Templates render successfully${NC}"
    else
        echo -e "${RED}✗ Template rendering failed${NC}"
        helm template test "$ROOT_DIR/helm/guestbook" 2>&1 | head -20
        ((ERRORS++))
    fi
else
    echo -e "${YELLOW}⚠ Helm not installed, skipping chart validation${NC}"
fi
echo ""

# -----------------------------------------------------------------------------
# Validate kubectl
# -----------------------------------------------------------------------------
echo -e "${YELLOW}[3/3] Dry-run validation with kubectl...${NC}"

if command -v kubectl &> /dev/null; then
    for file in "$ROOT_DIR/bootstrap/cluster"/*.yaml; do
        if kubectl apply --dry-run=client -f "$file" > /dev/null 2>&1; then
            echo -e "${GREEN}  ✓ $(basename $file)${NC}"
        else
            echo -e "${RED}  ✗ $(basename $file)${NC}"
            ((ERRORS++))
        fi
    done
else
    echo -e "${YELLOW}⚠ kubectl not installed, skipping dry-run${NC}"
fi
echo ""

# -----------------------------------------------------------------------------
# Summary
# -----------------------------------------------------------------------------
echo -e "${BLUE}=============================================${NC}"
if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}  All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}  Found $ERRORS error(s)${NC}"
    exit 1
fi
