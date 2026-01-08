# Maria Guestbook — CI/CD Course Final Project

**Student:** Maria Vulcu
**Course:** CI/CD
**Date:** January 2026

---

## 🌐 Live Application

**URL:** https://maria-guestbook.cicd.cachefly.site

---

## 📋 Project Requirements

This project implements a GitOps-based CI/CD pipeline where:

1. ✅ **Guestbook is accessible via URL** — Messages persist across sessions
2. ✅ **Code changes trigger automatic builds** — New container images published to GHCR
3. ✅ **ArgoCD deploys automatically** — Infrastructure repo changes apply within 3 minutes
4. ✅ **YAML changes are applied automatically** — Scaling, config changes via GitOps

---

## 🏗️ Architecture

### Two-Repository Pattern

| Repository | Purpose | URL |
|------------|---------|-----|
| **Application** | Source code, CI pipeline | [maria-guestbook-app](https://github.com/mvulcu/maria-guestbook-app) |
| **Infrastructure** | Helm charts, ArgoCD configs | [maria-guestbook-infra](https://github.com/mvulcu/maria-guestbook-infra) |

### Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| Orchestration | K3s | Lightweight Kubernetes on VPS |
| GitOps | ArgoCD | Continuous Deployment |
| CI | GitHub Actions | Build, Test, Scan, Deploy |
| Registry | GHCR | Container image storage |
| Packaging | Helm | Kubernetes templating |
| Backend | Go 1.24 | API server |
| Frontend | Nginx Alpine | Static file serving |
| Database | PostgreSQL 15 | Persistent storage |
| Cache | Redis 7 | Caching layer |
| Progressive Delivery | Argo Rollouts | Canary deployments |

### Architecture Diagram

```
Developer → Push Code → GitHub Actions (Build/Test/Scan) → GHCR
                                    ↓
                        Update image tag in Infra Repo
                                    ↓
                            ArgoCD detects change
                                    ↓
                    Argo Rollouts (Canary: 20% → 100%)
                                    ↓
                        K3s Cluster (VPS)
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow (`.github/workflows/ci.yaml`)

The pipeline runs 4 sequential jobs:

| Job | Tool | Purpose |
|-----|------|---------|
| 1. Lint | golangci-lint | Code quality checks |
| 2. Test | go test | Unit tests |
| 3. Build & Scan | Docker + Trivy | Build images, scan for vulnerabilities |
| 4. Update Infra | git push | Update image tags in infra repo |

### Security Scanning

```yaml
- name: Scan with Trivy
  uses: aquasecurity/trivy-action@master
  with:
    exit-code: '1'
    severity: 'CRITICAL,HIGH'
```

**Policy:** Build fails on CRITICAL or HIGH vulnerabilities.

---

## ☸️ Kubernetes Deployment

### ArgoCD Configuration

**App-of-Apps Pattern:**
```
root-apps
├── argo-rollouts     → Installs Rollouts controller
└── maria-guestbook   → Deploys the application
```

**Sync Policy:**
- `prune: true` — Delete resources removed from Git
- `selfHeal: true` — Revert manual cluster changes
- Replica count is managed declaratively via Git (Helm values) to demonstrate core GitOps principles

### Canary Deployment Strategy

```yaml
strategy:
  canary:
    steps:
    - setWeight: 20   # 20% traffic to new version
    - pause: {}       # Manual verification step
    - setWeight: 100  # Full rollout
```

The pause step allows manual validation before promotion and can be skipped or promoted via Argo Rollouts UI when running in auto-sync mode.

---

## 🔐 Security Features

| Feature | Implementation |
|---------|----------------|
| Network Policies | Zero-trust (default-deny + explicit allow) |
| Secret Management | Manual creation via `setup-secrets.sh` |
| Container Scanning | Trivy (fail on CRITICAL/HIGH) |
| RBAC | Dedicated ServiceAccount with minimal permissions |
| Resource Quotas | Namespace-level CPU/memory limits |

### Network Policy Example

```
Frontend ← Ingress Controller (allowed)
Backend ← Frontend only (allowed)
Redis ← Backend only (allowed)
PostgreSQL ← Backend only (allowed)
```

---

## 📊 Resource Management

### ResourceQuota

```yaml
pods: 20
requests.cpu: 2
limits.cpu: 4
requests.memory: 2Gi
limits.memory: 4Gi
```

### Current Usage

| Resource | Used | Limit |
|----------|------|-------|
| Pods | 6/20 | 30% |
| CPU | 450m/2 | 23% |
| Memory | 576Mi/2Gi | 28% |

---

## 🧪 Testing

### Backend Unit Tests

```bash
cd backend
go test -v ./...
```

**Coverage:** Health endpoint validation, error handling.

### Manual Verification

1. Open https://maria-guestbook.cicd.cachefly.site
2. Submit a message → should appear immediately
3. Open incognito → message should persist

---

## 📁 Project Structure

```
maria-guestbook-app/
├── backend/
│   ├── main.go           # API server (Go)
│   ├── main_test.go      # Unit tests
│   ├── go.mod
│   └── Dockerfile
├── frontend/
│   ├── index.html        # Main page
│   ├── script.js         # Client logic
│   ├── styles.css        # Cyberpunk styling
│   ├── nginx.conf
│   └── Dockerfile
└── .github/workflows/
    └── ci.yaml           # CI pipeline

maria-guestbook-infra/
├── argocd/
│   ├── app-of-apps.yaml  # Root application
│   ├── guestbook.yaml    # Main app
│   └── argo-rollouts.yaml
├── helm/guestbook/
│   ├── Chart.yaml
│   ├── values.yaml       # Configuration
│   └── templates/
├── bootstrap/            # Initial setup
└── scripts/
    └── setup-secrets.sh
```

---

## 🚀 Deployment Instructions

### Prerequisites
- K3s cluster with ArgoCD installed
- GitHub repository access
- GHCR authentication

### Initial Setup

```bash
# 1. Bootstrap ArgoCD
kubectl apply -f bootstrap/argocd/

# 2. Create secrets
./scripts/setup-secrets.sh

# 3. Deploy root application
kubectl apply -f argocd/app-of-apps.yaml
```

### Scaling (Teacher Test)

Replica count is defined declaratively in Git via Helm values and is the single source of truth.

To verify scaling from X to X+2, modify `values.yaml`:

```yaml
backend:
  replicaCount: X+2
```

Commit and push the change. ArgoCD will automatically detect the difference between Git and the cluster and reconcile the desired number of replicas.

---

## 👥 Collaborators

- `jonasbjork` (Course Instructor)

---

## 📄 License

MIT
