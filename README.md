<p align="center">
  <a href="https://maria-guestbook.cicd.cachefly.site">
    <img src="https://img.shields.io/badge/🌐 Live Demo-maria--guestbook-1abc9c?style=for-the-badge" alt="Live Demo">
  </a>
  <a href="https://github.com/mvulcu/maria-guestbook-app">
    <img src="https://img.shields.io/badge/📦 App Repo-GitHub-181717?style=for-the-badge&logo=github" alt="App Repo">
  </a>
  <a href="https://github.com/mvulcu/maria-guestbook-infra">
    <img src="https://img.shields.io/badge/🏗️ Infra Repo-GitHub-181717?style=for-the-badge&logo=github" alt="Infra Repo">
  </a>
</p>

---

# Maria Guestbook — GitOps Production Showcase

**Student:** Maria Vulcu  
**Course:** CI/CD  
**Date:** January 2026

---

## 🎯 Project Evolution

**From Assignment to Production Showcase**

This started as a CI/CD course final project with basic requirements, but I chose to go beyond — transforming it into a comprehensive GitOps demonstration that mirrors enterprise practices.

### ✅ What Was Required

The assignment asked for:
- ✅ Guestbook accessible via URL with persistent messages
- ✅ Automatic builds triggered by code changes
- ✅ Container images published to GHCR
- ✅ ArgoCD auto-deployment within 3 minutes
- ✅ Automatic YAML changes application via GitOps

### 🚀 What I Actually Built

Going beyond the assignment, I implemented:
- **Advanced Deployments**: Canary rollouts with Argo Rollouts and automatic rollback
- **Complete Observability**: Prometheus + Grafana + Loki stack for metrics and logs
- **Production Security**: Zero-trust NetworkPolicies, Sealed Secrets, Trivy scanning
- **Operational Excellence**: Automated backups, Discord alerting, ArgoCD Image Updater
- **Two-repo GitOps pattern**: Clean separation of app and infrastructure concerns
- **CI/CD Pipeline**: GitHub Actions with security scanning that fails on CRITICAL/HIGH vulnerabilities

**Why?** Because I believe in building systems that are production-ready, not just assignment-complete.

> *"I don't look for easy paths."*

---

## 🌐 Live Application

**URL:** https://maria-guestbook.cicd.cachefly.site

---

## 🏗️ Architecture

### Two-Repository Pattern

| Repository | Purpose | URL |
|------------|---------|-----|
| **Application** | Source code, CI pipeline | [maria-guestbook-app](https://github.com/mvulcu/maria-guestbook-app) |
| **Infrastructure** | Helm charts, ArgoCD configs | [maria-guestbook-infra](https://github.com/mvulcu/maria-guestbook-infra) |

This separation enables:
- Independent versioning and release cycles
- Clear ownership boundaries
- Reduced blast radius of changes
- Real-world enterprise GitOps practices

### Technology Stack

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Orchestration** | K3s | Lightweight Kubernetes on VPS |
| **GitOps** | ArgoCD | Continuous Deployment |
| **Progressive Delivery** | Argo Rollouts | Canary deployments with rollback |
| **CI/CD** | GitHub Actions | Build, Test, Scan, Deploy |
| **Registry** | GHCR | Container image storage |
| **Packaging** | Helm | Kubernetes templating |
| **Backend** | Go 1.24 | API server |
| **Frontend** | Nginx Alpine | Static file serving |
| **Database** | PostgreSQL 15 | Persistent storage |
| **Cache** | Redis 7 | Caching layer |
| **Metrics** | Prometheus | Metric collection |
| **Dashboards** | Grafana | Visualization & alerting |
| **Logging** | Loki + Promtail | Centralized log aggregation |
| **Secrets** | Sealed Secrets | GitOps-encrypted secrets |
| **Security Scanning** | Trivy | Container vulnerability detection |

### Architecture Flow

```
┌─────────────────────────────────────────────────────────────┐
│                        Developer Push                       │
└────────────────────────┬────────────────────────────────────┘
                         │
                         v
┌─────────────────────────────────────────────────────────────┐
│               GitHub Actions CI Pipeline                    │
│  ┌──────────┐  ┌──────────┐  ┌──────────────┐  ┌─────────┐  │
│  │   Lint   │→ │   Test   │→ │ Build + Scan │→ │ Push to │  │
│  │ (golint) │  │ (go test)│  │   (Trivy)    │  │  GHCR   │  │
│  └──────────┘  └──────────┘  └──────────────┘  └─────────┘  │
└────────────────────────┬────────────────────────────────────┘
                         │
                         v (update image tag)
┌─────────────────────────────────────────────────────────────┐
│              Infrastructure Repository                      │
│              helm/guestbook/values.yaml                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         v (ArgoCD polls Git every 3 min)
┌─────────────────────────────────────────────────────────────┐
│                    ArgoCD Sync                              │
│              (detects diff → reconcile)                     │
└────────────────────────┬────────────────────────────────────┘
                         │
                         v
┌─────────────────────────────────────────────────────────────┐
│                  Argo Rollouts Strategy                     │
│         20% canary → pause → 100% rollout                   │
│              (with automatic rollback)                      │
└────────────────────────┬────────────────────────────────────┘
                         │
                         v
┌─────────────────────────────────────────────────────────────┐
│                   K3s Cluster (VPS)                         │
│  ┌──────────┐  ┌──────────┐  ┌───────────┐  ┌───────────┐   │
│  │ Frontend │  │ Backend  │  │PostgreSQL │  │   Redis   │   │
│  │  (Nginx) │  │   (Go)   │  │    (PVC)  │  │ (Cache)   │   │
│  └──────────┘  └──────────┘  └───────────┘  └───────────┘   │
│                                                             │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Observability Stack                          │   │
│  │  Prometheus → Grafana → Loki → Discord Alerts        │   │
│  └──────────────────────────────────────────────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🔄 CI/CD Pipeline

### GitHub Actions Workflow (`.github/workflows/ci.yaml`)

The pipeline runs 4 sequential jobs ensuring code quality and security:

| Job | Tool | Purpose | Fail Condition |
|-----|------|---------|----------------|
| 1. **Lint** | golangci-lint | Code quality checks | Linting errors |
| 2. **Test** | go test | Unit tests | Test failures |
| 3. **Build & Scan** | Docker + Trivy | Build images, scan vulnerabilities | CRITICAL/HIGH CVEs |
| 4. **Update Infra** | git push | Update image tags in infra repo | Push failure |

### Security Scanning

```yaml
- name: Scan with Trivy
  uses: aquasecurity/trivy-action@master
  with:
    exit-code: '1'
    severity: 'CRITICAL,HIGH'
```

**Policy:** Build fails on CRITICAL or HIGH vulnerabilities. No vulnerable images reach production.

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

Progressive traffic shifting with manual validation gate:

```yaml
strategy:
  canary:
    steps:
    - setWeight: 20   # 20% traffic to new version
    - pause: {}       # Manual verification step
    - setWeight: 100  # Full rollout
```

**Benefits:**
- Gradual exposure limits blast radius
- Manual gate allows smoke testing
- Automatic rollback on failed health checks
- Zero-downtime deployments

The pause step allows manual validation before promotion and can be skipped or promoted via Argo Rollouts UI when running in auto-sync mode.

---

## 🔐 Security Features

### Defense in Depth

| Layer | Implementation | Purpose |
|-------|----------------|---------|
| **Build** | Trivy scanning | Block vulnerable images |
| **Network** | NetworkPolicies | Zero-trust pod isolation |
| **Secrets** | Sealed Secrets | GitOps-safe secret management |
| **Access** | RBAC | Least-privilege service accounts |
| **Runtime** | Security Context | Non-root, dropped capabilities |
| **Resources** | ResourceQuotas | Prevent resource exhaustion |

### Network Policy Example

Zero-trust architecture with explicit allow rules:

```
Frontend ← Ingress Controller (allowed)
Backend ← Frontend only (allowed)
Redis ← Backend only (allowed)
PostgreSQL ← Backend only (allowed)

All other traffic: DENIED by default
```

### Sealed Secrets

Secrets encrypted with cluster-specific key, safe to commit to Git:

```bash
# Create sealed secret
kubectl create secret generic db-creds \
  --from-literal=password=supersecret \
  --dry-run=client -o yaml | \
kubeseal -o yaml > sealed-secret.yaml

# Commit to Git (encrypted)
git add sealed-secret.yaml
git commit -m "Add database credentials"
```

---

## 📡 Monitoring & Observability

### Stack Overview

| Component | Technology | Purpose |
|-----------|------------|---------|
| **Metrics** | Prometheus | Metric collection & storage |
| **Visualization** | Grafana | Dashboards & charts |
| **Logging** | Loki + Promtail | Centralized log aggregation |
| **Alerting** | Grafana → Discord | Incident notifications |

### ServiceMonitor

Backend metrics are automatically scraped by Prometheus via `ServiceMonitor` CRD:

```yaml
# helm/guestbook/templates/app/servicemonitor.yaml
endpoints:
  - port: http
    interval: 30s
    path: /metrics
```

### Grafana Dashboards

Deployed automatically via Grafana sidecar (ConfigMap with `grafana_dashboard` label):

| Dashboard | Metrics |
|-----------|---------|
| **Maria Guestbook** | Request rate, latency (p50/p95/p99), error rate, HTTP status codes |
| **SRE Overview** | SLO metrics, pod health, CPU/Memory usage, live log stream |

### Alerting Rules

Grafana alerts configured with Discord webhook integration:

| Alert | Condition | Severity |
|-------|-----------|----------|
| 🔴 **Pod Down** | Running pods < expected replicas | Critical |
| 🟠 **High Memory** | Memory usage > 80% | Warning |
| ⚠️ **Pod Restarts** | Restart count increased | Warning |
| 🔴 **High Error Rate** | 5xx responses > 5% | Critical |

---

## 🔔 ArgoCD Notifications

Discord notifications for deployment lifecycle events:

| Event | Emoji | Trigger |
|-------|-------|---------|
| Sync Running | 🔄 | ArgoCD sync started |
| Sync Succeeded | ✅ | All resources healthy |
| Sync Failed | ❌ | Sync error occurred |
| Health Degraded | ⚠️ | Resource health check failed |
| Deployed (Healthy) | 💚 | Application fully deployed |

**Configuration:**
```yaml
# argocd-notifications-cm.yaml
service.discord: |
  token: $discord-token
trigger.on-deployed: |
  - when: app.status.operationState.phase == 'Succeeded'
    send: [app-deployed]
```

---

## 🔄 ArgoCD Image Updater

Automatic image tag updates without manual intervention:

```yaml
# Annotations on Application
argocd-image-updater.argoproj.io/image-list: backend=ghcr.io/mvulcu/maria-guestbook-backend
argocd-image-updater.argoproj.io/backend.update-strategy: latest
argocd-image-updater.argoproj.io/write-back-method: git
```

**Flow:** 
1. New image pushed to GHCR
2. Image Updater detects new tag
3. Commits updated tag to infra repo
4. ArgoCD syncs automatically

**Result:** Hands-free deployments from code push to production.

---

## 💾 PostgreSQL Backup

Automated daily backups with retention policy:

| Setting | Value |
|---------|-------|
| **Schedule** | Daily at 2:00 AM (CronJob) |
| **Retention** | 7 days (rolling) |
| **Method** | `pg_dump` to PVC |
| **Compression** | gzip |

### Manual Backup

```bash
# Trigger immediate backup
kubectl create job --from=cronjob/postgres-backup manual-backup -n maria-guestbook

# List backups
kubectl exec -it postgres-0 -n maria-guestbook -- ls -lh /backups

# Restore from backup
kubectl exec -it postgres-0 -n maria-guestbook -- \
  psql guestbook < /backups/guestbook-2025-02-03.sql.gz
```

---

## 📊 Resource Management

### ResourceQuota

Namespace-level limits prevent resource exhaustion:

```yaml
spec:
  hard:
    pods: "20"
    requests.cpu: "2"
    limits.cpu: "4"
    requests.memory: "2Gi"
    limits.memory: "4Gi"
```

### Current Usage

| Resource | Used | Limit | Utilization |
|----------|------|-------|-------------|
| Pods | 6 | 20 | 30% |
| CPU | 450m | 2000m | 23% |
| Memory | 576Mi | 2Gi | 28% |

**Headroom:** Sufficient capacity for scaling and deployments.

---

## 🧪 Testing

### Backend Unit Tests

```bash
cd backend
go test -v ./...
```

**Coverage:**
- Health endpoint validation
- Error handling
- Database connection logic

### Manual Verification

1. Open https://maria-guestbook.cicd.cachefly.site
2. Submit a message → should appear immediately in the list
3. Open incognito window → message should persist (database verification)
4. Refresh page → message still visible (cache + database verification)

### CI/CD Verification

```bash
# Trigger pipeline
git commit -m "test: verify CI/CD" --allow-empty
git push

# Watch ArgoCD sync
kubectl get applications -n argocd -w

# Verify canary rollout
kubectl argo rollouts get rollout backend -n maria-guestbook -w
```

---

## 📁 Project Structure

```
maria-guestbook-app/
├── backend/
│   ├── main.go           # API server (Go)
│   ├── main_test.go      # Unit tests
│   ├── go.mod
│   └── Dockerfile        # Multi-stage build
├── frontend/
│   ├── index.html        # Main page
│   ├── script.js         # Client logic
│   ├── styles.css        # Cyberpunk styling
│   ├── nginx.conf        # Nginx configuration
│   └── Dockerfile        # Nginx Alpine base
└── .github/workflows/
    └── ci.yaml           # CI pipeline (lint → test → build → scan → deploy)

maria-guestbook-infra/
├── argocd/
│   ├── app-of-apps.yaml  # Root application
│   ├── guestbook.yaml    # Main app + Image Updater annotations
│   ├── argo-rollouts.yaml
│   └── image-updater.yaml
├── helm/guestbook/
│   ├── Chart.yaml
│   ├── values.yaml       # Configuration (single source of truth)
│   └── templates/
│       ├── app/
│       │   ├── backend-deployment.yaml
│       │   ├── backend-rollout.yaml      # Canary strategy
│       │   ├── frontend-deployment.yaml
│       │   ├── servicemonitor.yaml       # Prometheus scraping
│       │   └── grafana-dashboard.yaml    # Dashboard ConfigMap
│       ├── secrets/
│       │   └── sealed-secrets.yaml       # Encrypted secrets
│       ├── postgres/
│       │   ├── statefulset.yaml
│       │   ├── pvc.yaml
│       │   └── backup-cronjob.yaml       # Daily backups
│       ├── redis/
│       │   └── deployment.yaml
│       ├── network/
│       │   └── network-policies.yaml     # Zero-trust rules
│       └── notifications/
│           └── argocd-notifications-cm.yaml  # Discord alerts
├── monitoring/
│   ├── prometheus/
│   └── grafana/
├── bootstrap/            # Initial cluster setup
└── scripts/
    └── setup-secrets.sh  # Helper for initial secret creation
```

---

## 🚀 Deployment Instructions

### Prerequisites

- K3s cluster with ArgoCD installed
- GitHub repository access
- GHCR authentication configured
- `kubectl` and `kubeseal` CLI tools

### Initial Setup

```bash
# 1. Clone repositories
git clone https://github.com/mvulcu/maria-guestbook-app
git clone https://github.com/mvulcu/maria-guestbook-infra

# 2. Bootstrap ArgoCD
kubectl apply -f maria-guestbook-infra/bootstrap/argocd/

# 3. Create sealed secrets
cd maria-guestbook-infra
./scripts/setup-secrets.sh

# 4. Deploy root application (App-of-Apps pattern)
kubectl apply -f argocd/app-of-apps.yaml

# 5. Wait for sync
kubectl get applications -n argocd -w
```

### Scaling Verification

**GitOps Principle**: Replica count is the single source of truth in Git.

To test scaling from X to X+2 replicas:

1. **Edit** `helm/guestbook/values.yaml`:
   ```yaml
   backend:
     replicaCount: 5  # or any desired number
   ```

2. **Commit and push**:
   ```bash
   git add helm/guestbook/values.yaml
   git commit -m "Scale backend to 5 replicas"
   git push
   ```

3. **ArgoCD detects the change** within 3 minutes and reconciles:
   ```bash
   # Watch the rollout
   kubectl get pods -n maria-guestbook -w
   
   # Verify replica count
   kubectl get deployment backend -n maria-guestbook
   ```

**Expected Result**: Deployment scales from current count to new count automatically, demonstrating declarative GitOps principles.

---

## 🎓 Key Learnings

Working on this project taught me that **meeting requirements is just the baseline**. Real engineering is about:

### Technical Insights

- **Security by Design**: Implementing zero-trust from day one, not as an afterthought. NetworkPolicies, Sealed Secrets, and vulnerability scanning aren't optional — they're foundational.

- **Observability First**: You can't fix what you can't see. Metrics, logs, and alerts need to be built into the architecture, not bolted on later.

- **GitOps Discipline**: Treating Git as the single source of truth requires architectural thinking. It's not just about automation — it's about creating a system where the desired state is always clear and auditable.

- **Progressive Delivery**: Canary deployments aren't just fancy — they prevent production disasters. The manual gate gives confidence; the automatic rollback gives safety.

- **Day-2 Operations**: Backups, monitoring, alerting — the unglamorous but essential work that keeps systems running when things go wrong.

### Engineering Philosophy

> *"Sometimes I break things on purpose — just to see if my recovery scripts really work."*

This project reinforced my belief that good DevOps isn't about perfect systems — it's about systems that fail gracefully, recover automatically, and teach you something when they break.

The two-repository pattern taught me about separation of concerns. The observability stack taught me about operational empathy. The security layers taught me about defense in depth.

But most importantly: **this project taught me that going beyond requirements isn't about showing off — it's about building muscle memory for production thinking.**

---

## ⚠️ Known Limitations & Future Improvements

### Current Limitations

- **Single VPS deployment**: No multi-node high availability or geographic distribution
- **Manual canary promotion**: Requires human intervention at the pause step
- **Limited test coverage**: Only unit tests, no integration or e2e tests
- **No automated performance testing**: Load testing is manual

---

## 👥 Collaborators

- **jonasbjork** (Course Instructor)

---

## 📄 License

MIT

---

<p align="center">
  <em>Built with ❤️ by Maria Vulcu</em><br/>
  <a href="https://grepme.dev">grepme.dev</a> · 
  <a href="mailto:ping@grepme.dev">ping@grepme.dev</a> · 
  <a href="https://linkedin.com/in/mariavulcu">LinkedIn</a>
</p>
