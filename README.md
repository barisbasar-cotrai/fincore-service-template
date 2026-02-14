# FinCore IDP — Platform Architect Assessment Demo

## Project Structure

```
IDP/
├── docs/
│   ├── architecture.md              # Full IDP architecture & platform operating model
│   └── presentation-stories.md      # Key concepts, narratives, analysis
│
├── terraform/platform/              # Platform infrastructure (managed by Platform Team)
│   ├── providers.tf                 # Azure provider, state backend config
│   ├── variables.tf                 # Location, VM size, node count
│   ├── main.tf                      # AKS + ACR + VNet + Subnet + Log Analytics
│   └── outputs.tf                   # Cluster name, ACR server, kubeconfig command
│
├── service-template/                # Golden Path template (what developers clone)
│   ├── src/
│   │   ├── __init__.py
│   │   └── main.py                  # FastAPI service: /health, /metrics, /api/v1/accounts
│   ├── tests/
│   │   └── test_main.py             # Unit tests
│   ├── requirements.txt             # fastapi, uvicorn, prometheus-client
│   ├── Dockerfile                   # Multi-stage, non-root (USER 1000)
│   ├── k8s/
│   │   ├── namespace.yaml           # fincore namespace
│   │   ├── deployment.yaml          # 2 replicas, probes, resource limits, prometheus annotations
│   │   ├── service.yaml             # ClusterIP on port 80 → 8000
│   │   └── servicemonitor.yaml      # Prometheus auto-discovery via CRD
│   ├── grafana/
│   │   └── dashboard.json           # RED metrics + pod resources dashboard
│   └── .github/workflows/
│       └── ci-cd.yaml               # Full pipeline: test → build → scan → push → deploy
│
└── platform/observability/          # Observability stack (deployed once)
    ├── kube-prometheus-values.yaml   # Prometheus + Grafana Helm values
    ├── loki-values.yaml              # Log aggregation Helm values
    └── deploy.sh                     # One-command observability setup
```

## Azure Resources

| Resource | Name | Purpose |
|---|---|---|
| Resource Group | `rg-fincore-dev` | Contains all resources |
| AKS Cluster | `aks-fincore-dev` | Kubernetes runtime (2x Standard_B2s_v2) |
| Container Registry | `acrfincoredev` | Docker image storage |
| Virtual Network | `vnet-fincore-dev` | Network isolation (10.0.0.0/16) |
| Subnet | `snet-aks` | AKS node subnet (10.0.1.0/24) |
| Log Analytics | `law-fincore-dev` | AKS monitoring addon |
| Service Principal | `github-actions-fincore` | GitHub Actions → Azure auth |

## GitHub Repository

- Repo: `barisbasar-cotrai/fincore-service-template`
- Secret: `AZURE_CREDENTIALS` (service principal JSON)
- Pipeline triggers on push to `main`

---

## Demo Playbook

### Before the presentation

**1. Verify everything is running:**

```bash
# Check AKS nodes
az aks get-credentials --resource-group rg-fincore-dev --name aks-fincore-dev
kubectl get nodes

# Check service pods
kubectl get pods -n fincore

# Check monitoring stack
kubectl get pods -n monitoring

# Test the API
kubectl run test --rm -it --restart=Never -n fincore \
  --image=curlimages/curl -- curl -s http://account-service/api/v1/accounts
```

**2. Start Grafana port-forward (keep this terminal open):**

```bash
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
```

Grafana: http://localhost:3000 — admin / fincore-demo

**3. Generate some traffic so dashboards have data:**

```bash
kubectl run loadtest --rm -it --restart=Never -n fincore \
  --image=curlimages/curl -- sh -c \
  'for i in $(seq 1 200); do
    curl -s http://account-service/api/v1/accounts > /dev/null
    curl -s http://account-service/api/v1/accounts/ACC001 > /dev/null
    curl -s http://account-service/api/v1/accounts/ACC002 > /dev/null
  done'
```

**4. Open these tabs in your browser before presenting:**

- Tab 1: GitHub repo (code view) — show the golden path structure
- Tab 2: GitHub Actions — show pipeline runs
- Tab 3: Grafana — "Account Service - Golden Path Dashboard"
- Tab 4: Grafana Explore with Loki — `{namespace="fincore"}`
- Tab 5: Terminal ready at the service-template directory

---

### Live Demo Script (during presentation)

**Step 1: Show the golden path template (2 min)**

Show the repo structure in GitHub or terminal:

```bash
ls -la /Users/barisbasar/codes/IDP/service-template/
ls -la /Users/barisbasar/codes/IDP/service-template/k8s/
ls -la /Users/barisbasar/codes/IDP/service-template/.github/workflows/
```

Talk through: "A developer clones this template. They get a working service with CI/CD, observability, security scanning — everything pre-wired."

**Step 2: Make a code change and push (2 min)**

Add a new endpoint to the service. Open `src/main.py` and add at the bottom:

```python
@app.get("/api/v1/accounts/{account_id}/balance")
async def get_balance(account_id: str):
    if account_id not in accounts:
        raise HTTPException(status_code=404, detail="Account not found")
    logger.info("Balance check: %s", account_id)
    return {"account_id": account_id, "balance": accounts[account_id]["balance"]}
```

Then push:

```bash
cd /Users/barisbasar/codes/IDP/service-template
git add -A && git commit -m "Add balance endpoint" && git push
```

**Step 3: Watch the pipeline (3 min)**

Switch to GitHub Actions tab — show the pipeline running:

```bash
gh run watch --repo barisbasar-cotrai/fincore-service-template
```

Talk through each stage as it runs: "Tests run, container builds, Trivy scans for vulnerabilities, pushes to ACR, deploys to AKS, verifies the rollout."

**Step 4: Verify the new endpoint works (1 min)**

```bash
kubectl run test --rm -it --restart=Never -n fincore \
  --image=curlimages/curl -- curl -s http://account-service/api/v1/accounts/ACC001/balance
```

Expected: `{"account_id": "ACC001", "balance": 15000.0}`

**Step 5: Show observability (2 min)**

Switch to Grafana dashboard tab — show:
- Request rate picking up the new deployment
- p95 latency
- Pod CPU/memory during deployment (rolling update visible)

Switch to Loki tab — query:
```
{namespace="fincore"} |= "Balance check"
```

Show the log from the new endpoint appearing.

**The punchline:** "A developer just shipped a feature to production in under 5 minutes. No tickets. No handoffs. No waiting for Cloud Engineering. Full observability from the moment it deployed. This is what every team at FinCore gets on day one with the golden path."

---

## Key Commands Reference

### Terraform

```bash
# Provision all infrastructure
cd /Users/barisbasar/codes/IDP/terraform/platform
terraform init
terraform apply

# Check what exists
terraform output

# Tear down everything (after the demo!)
terraform destroy
```

### AKS / kubectl

```bash
# Get credentials
az aks get-credentials --resource-group rg-fincore-dev --name aks-fincore-dev

# Check cluster
kubectl get nodes
kubectl get pods -n fincore
kubectl get pods -n monitoring
kubectl get svc -n fincore
kubectl get svc -n monitoring

# View pod logs
kubectl logs -n fincore -l app=account-service --tail=50

# Restart deployment (if needed)
kubectl rollout restart deployment/account-service -n fincore

# Check deployment status
kubectl rollout status deployment/account-service -n fincore

# Test service internally
kubectl run test --rm -it --restart=Never -n fincore \
  --image=curlimages/curl -- curl -s http://account-service/health

kubectl run test --rm -it --restart=Never -n fincore \
  --image=curlimages/curl -- curl -s http://account-service/api/v1/accounts

kubectl run test --rm -it --restart=Never -n fincore \
  --image=curlimages/curl -- curl -s http://account-service/metrics
```

### Docker / ACR

```bash
# Login to ACR
az acr login --name acrfincoredev

# Build for AMD64 (important on Apple Silicon!)
docker build --platform linux/amd64 -t acrfincoredev.azurecr.io/account-service:v1 .

# Push to ACR
docker push acrfincoredev.azurecr.io/account-service:v1

# List images in ACR
az acr repository list --name acrfincoredev
az acr repository show-tags --name acrfincoredev --repository account-service

# Build in the cloud (no local Docker needed)
az acr build --registry acrfincoredev --image account-service:v1 .
```

### Observability

```bash
# Deploy observability stack
/Users/barisbasar/codes/IDP/platform/observability/deploy.sh

# Access Grafana
kubectl port-forward -n monitoring svc/prometheus-grafana 3000:80
# URL: http://localhost:3000 — admin / fincore-demo

# Access Prometheus directly
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# URL: http://localhost:9090

# Check Prometheus targets (are services being scraped?)
# Go to http://localhost:9090/targets

# Generate traffic for dashboards
kubectl run loadtest --rm -it --restart=Never -n fincore \
  --image=curlimages/curl -- sh -c \
  'for i in $(seq 1 200); do
    curl -s http://account-service/api/v1/accounts > /dev/null
    curl -s http://account-service/api/v1/accounts/ACC001 > /dev/null
  done'
```

### GitHub Actions

```bash
# Check recent pipeline runs
gh run list --repo barisbasar-cotrai/fincore-service-template --limit 5

# Watch a running pipeline
gh run watch --repo barisbasar-cotrai/fincore-service-template

# View logs of latest run
gh run view --repo barisbasar-cotrai/fincore-service-template --log

# Trigger a run by pushing a change
cd /Users/barisbasar/codes/IDP/service-template
git add -A && git commit -m "your message" && git push
```

### Grafana Queries

**Prometheus (Metrics):**

```promql
# Request rate
rate(http_requests_total{namespace="fincore", pod=~"account-service.*"}[5m])

# Error rate percentage
sum(rate(http_requests_total{namespace="fincore", status=~"5.."}[5m])) / sum(rate(http_requests_total{namespace="fincore"}[5m])) * 100

# p95 latency
histogram_quantile(0.95, rate(http_request_duration_seconds_bucket{namespace="fincore"}[5m]))

# Total requests
http_requests_total{namespace="fincore"}
```

**Loki (Logs):**

```logql
# All fincore logs
{namespace="fincore"}

# Only account-service logs
{namespace="fincore", app="account-service"}

# Filter for specific log messages
{namespace="fincore"} |= "Balance check"
{namespace="fincore"} |= "Account not found"
```

---

## Pipeline Stages Explained

The CI/CD pipeline (`.github/workflows/ci-cd.yaml`) has 3 jobs:

### Job 1: test
- Runs on every push and PR
- Sets up Python 3.12
- Installs dependencies
- Runs `pytest` — 4 unit tests (health, list accounts, get account, not found)
- Runs `ruff` linter on source code

### Job 2: build-and-push (only on main)
- Builds Docker container image
- Tags with commit SHA (immutable) and `latest`
- Scans with **Trivy** for CRITICAL vulnerabilities — fails the pipeline if found
- Logs into ACR via Azure service principal
- Pushes both tags to ACR

### Job 3: deploy (only on main)
- Sets AKS context via service principal
- Replaces `IMAGE_PLACEHOLDER` in deployment.yaml with the actual image+SHA
- Applies all K8s manifests (namespace, deployment, service, servicemonitor)
- Waits for rollout to complete (120s timeout)
- Creates/updates Grafana dashboard ConfigMap
- Runs smoke test (curl /health from inside the cluster)

---

## Dockerfile Explained

```dockerfile
# Stage 1: Install dependencies in a builder
FROM python:3.12-slim AS builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# Stage 2: Copy only what's needed into a clean image
FROM python:3.12-slim
WORKDIR /app
COPY --from=builder /install /usr/local
COPY src/ .
EXPOSE 8000
USER 1000  # Run as non-root (security best practice)
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

Why multi-stage:
- Smaller final image (no build tools, no pip cache)
- Fewer layers = smaller attack surface
- Non-root user = if container is compromised, attacker has limited permissions

---

## Troubleshooting

### Pods stuck in ImagePullBackOff
```bash
# Check the error
kubectl describe pod -n fincore $(kubectl get pods -n fincore -o jsonpath='{.items[0].metadata.name}')

# Common causes:
# 1. Wrong architecture — rebuild with: docker build --platform linux/amd64
# 2. ACR auth — reattach: az aks update --name aks-fincore-dev --resource-group rg-fincore-dev --attach-acr acrfincoredev
# 3. Image doesn't exist — check: az acr repository show-tags --name acrfincoredev --repository account-service
```

### Pipeline fails at test stage
```bash
# Run tests locally first
cd /Users/barisbasar/codes/IDP/service-template
pip install -r requirements.txt pytest httpx
pytest tests/ -v
```

### Grafana shows "No data"
```bash
# Check Prometheus is scraping the service
kubectl port-forward -n monitoring svc/prometheus-kube-prometheus-prometheus 9090:9090
# Go to http://localhost:9090/targets — look for account-service

# Check ServiceMonitor exists
kubectl get servicemonitor -n fincore

# Verify metrics endpoint works
kubectl run test --rm -it --restart=Never -n fincore \
  --image=curlimages/curl -- curl -s http://account-service/metrics
```

### Loki not showing logs
```bash
# Check Promtail is running
kubectl get pods -n monitoring | grep promtail

# Check Loki is reachable
kubectl run test --rm -it --restart=Never -n monitoring \
  --image=curlimages/curl -- curl -s http://loki:3100/ready

# Add Loki datasource manually in Grafana:
# Settings → Data sources → Add → Loki → URL: http://loki:3100 → Save
```

### Terraform issues
```bash
# If apply hangs on a fresh subscription, skip provider registration:
# Add to providers.tf: skip_provider_registration = true

# If VM size not available, check allowed sizes:
az vm list-sizes --location westeurope --output table | grep Standard_B

# Check current state
terraform state list
terraform show
```

---

## Cleanup (after the demo)

```bash
# Destroy all Azure resources
cd /Users/barisbasar/codes/IDP/terraform/platform
terraform destroy

# Delete the service principal
az ad sp delete --id 8045b5ac-f83d-4bc9-ba31-c97cd9ec727c

# Delete the GitHub repo (optional)
gh repo delete barisbasar-cotrai/fincore-service-template --yes
```
