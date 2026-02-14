# FinCore IDP — Architecture & Platform Operating Model

## Assumptions

1. Azure is the cloud provider (assessment says "a major cloud provider" — we pick Azure).
2. GitHub is used for source control and CI/CD (assessment doesn't specify — we choose GitHub for its Actions integration).
3. FinCore's existing services are containerized or can be containerized.
4. Cloud Engineering team has some Kubernetes and Terraform knowledge.
5. The 6-month deadline means we focus on highest-impact changes first — not a complete transformation.
6. "Single tenant per instance" means each customer gets their own deployment of the microservices stack.
7. We are NOT replacing the existing product — we're building the platform that accelerates development and deployment of the new SaaS product.

---

## Platform Operating Model

### Team Structure (Team Topologies)

```
BEFORE (Current State)                    AFTER (Target State)
========================                  ========================

17 Product Teams                          17 Stream-Aligned Teams
   │                                         │
   │ tickets/requests                        │ self-service via IDP
   ▼                                         ▼
1 Cloud Engineering ◄── bottleneck       Platform Team (evolved from
1 QA Team           ◄── bottleneck         Cloud Eng + QA automation)
1 Security Team                              │
                                             │ provides
                                             ▼
                                          Internal Developer Platform
                                             │
                                          Security Team → becomes
                                          Complicated-Subsystem Team
                                          (embeds policies into platform)
```

#### Platform Team (evolved from Cloud Engineering)
- **Size:** Start with the existing Cloud Engineering team + 2-3 QA engineers who shift to automation
- **Mission:** Build and operate the IDP. Treat it as a product. Developers are customers.
- **Owns:** AKS clusters, golden path templates, CI/CD pipelines, observability stack, Terraform modules, platform security baseline
- **Does NOT own:** Application code, feature decisions, service-specific configurations
- **Interaction mode with product teams:** X-as-a-Service (primary), Facilitating (during adoption)

#### Stream-Aligned Teams (the 17 product teams)
- **Shift:** From "write code and hand off" to "own your service end-to-end"
- **New responsibility:** Deploy their own services (via golden path), monitor their own services, manage service-level configs
- **What they DON'T need to know:** Kubernetes internals, Terraform details, cluster operations. The platform handles this.

#### Security Team → Complicated-Subsystem Team
- **Shift:** From gate-keeper at the end to policy-as-code embedded in the platform
- **New responsibility:** Define compliance policies as OPA/Gatekeeper rules, maintain container scanning configs, manage secrets strategy
- **Interaction mode:** Collaboration with Platform Team to embed policies, X-as-a-Service for product teams

#### QA Transformation
- **Current:** Separate QA team, manual testing at end of sprint
- **Target:** QA engineers embedded in product teams + test automation in the golden path pipeline
- **Platform provides:** Testing stage in CI/CD pipeline, test environment provisioning, quality gates (code coverage, linting, security scan)
- **Product teams own:** Writing their own tests (unit, integration, contract)

### Interaction Model

```
Product Teams ──── X-as-a-Service ────► IDP (Platform Team's product)

Product Teams ──── Facilitating ──────► Platform Team (during onboarding)

Security Team ──── Collaboration ─────► Platform Team (embedding policies)
```

### Platform as a Product — Governance

- Platform team has a product backlog, prioritized by developer pain points
- Feedback loop: regular surveys, office hours, embedded time with product teams
- Success metrics:
  - Time from code commit to production (lead time) — target: < 30 minutes
  - Time to onboard a new service — target: < 1 day
  - Deployment frequency — target: multiple per day per team
  - Developer satisfaction (NPS or similar)
  - Platform adoption rate (% of teams using golden path)
  - Cloud cost per service

---

## IDP Architecture

### High-Level Overview

```
┌─────────────────────────────────────────────────────────────────────┐
│                     DEVELOPER EXPERIENCE                            │
│                                                                     │
│   Template Repo          GitHub               CLI / Docs            │
│   (Golden Path)        (Source of Truth)     (Platform Guide)       │
└──────────┬──────────────────┬──────────────────┬────────────────────┘
           │                  │                  │
           ▼                  ▼                  ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   INTEGRATION & DELIVERY                            │
│                                                                     │
│   GitHub Actions Pipeline                                           │
│   ┌─────────┐ ┌──────┐ ┌──────────┐ ┌───────┐ ┌────────────────┐  │
│   │  Build   │→│ Test │→│ Security │→│ Push  │→│    Deploy       │  │
│   │Container │ │      │ │  Scan    │ │to ACR │ │  (kubectl/AKS) │  │
│   └─────────┘ └──────┘ └──────────┘ └───────┘ └────────────────┘  │
└──────────────────────────────────────┬──────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     RESOURCE PLANE (Azure)                          │
│                                                                     │
│   Terraform Modules (managed by Platform Team)                      │
│                                                                     │
│   ┌─────────┐  ┌─────────┐  ┌──────────────┐  ┌────────────────┐  │
│   │   AKS   │  │   ACR   │  │ Key Vault    │  │ Azure Monitor  │  │
│   │ Cluster │  │Registry │  │ (Secrets)    │  │ / Log Analytics│  │
│   └─────────┘  └─────────┘  └──────────────┘  └────────────────┘  │
│                                                                     │
│   ┌─────────┐  ┌─────────────┐  ┌──────────────────────────────┐  │
│   │Azure DB │  │ Storage     │  │ Virtual Network / Subnets    │  │
│   │(per svc)│  │ Account     │  │ NSGs / Private Endpoints     │  │
│   └─────────┘  └─────────────┘  └──────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                   OBSERVABILITY PLANE                                │
│                                                                     │
│   ┌────────────┐  ┌─────────┐  ┌──────────────────────────────┐   │
│   │ Prometheus │  │ Grafana │  │ Loki (Log Aggregation)       │   │
│   │ (Metrics)  │  │(Dashbds)│  │                              │   │
│   └────────────┘  └─────────┘  └──────────────────────────────┘   │
│                                                                     │
│   Every service auto-discovered via pod annotations                 │
│   Pre-built dashboards per service (RED metrics)                    │
│   Alerting rules for SLOs                                           │
└─────────────────────────────────────────────────────────────────────┘
                                       │
                                       ▼
┌─────────────────────────────────────────────────────────────────────┐
│                     SECURITY PLANE                                  │
│                                                                     │
│   ┌──────────────────┐  ┌──────────────┐  ┌────────────────────┐  │
│   │ OPA / Gatekeeper │  │ Trivy        │  │ Azure Key Vault    │  │
│   │ (Policy as Code) │  │ (Image Scan) │  │ (Secrets Mgmt)     │  │
│   └──────────────────┘  └──────────────┘  └────────────────────┘  │
│                                                                     │
│   ┌──────────────────┐  ┌──────────────────────────────────────┐  │
│   │ Network Policies │  │ RBAC (Azure AD + K8s)                │  │
│   └──────────────────┘  └──────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────────┘
```

### Golden Path — What a Developer Experiences

```
Developer wants to create a new service:

1. Clone the golden-path template repo
   $ gh repo create fincore-order-service --template fincore/service-template

2. The template includes:
   ├── src/                    # FastAPI application scaffold
   │   ├── main.py             # App entrypoint with health + metrics endpoints
   │   └── ...
   ├── tests/                  # Test scaffold
   ├── Dockerfile              # Multi-stage build, optimized
   ├── k8s/                    # Plain Kubernetes manifests
   │   ├── deployment.yaml     # Parameterized with env vars / kustomize
   │   ├── service.yaml
   │   ├── ingress.yaml
   │   └── servicemonitor.yaml # Prometheus auto-discovery
   ├── terraform/              # Service-specific infra (optional)
   │   └── main.tf             # e.g., database, storage — uncomment what you need
   ├── .github/
   │   └── workflows/
   │       └── ci-cd.yaml      # Full pipeline: build → test → scan → push → deploy
   ├── grafana/
   │   └── dashboard.json      # Pre-built Grafana dashboard for this service
   └── README.md               # How to develop, test, deploy

3. Developer configures service name in a single config file
4. Developer writes application code
5. Developer pushes to main
6. Pipeline automatically:
   - Builds container image
   - Runs tests
   - Scans for vulnerabilities (Trivy)
   - Pushes to ACR
   - Applies K8s manifests to AKS
   - Registers Grafana dashboard
7. Service is live with full observability

Note on Helm: For the demo we use plain manifests for transparency.
At FinCore's scale (17 teams, multiple environments), Helm would be
introduced for templating and release management. Plain manifests
are the right starting point — add Helm when the complexity demands it.
```

### CI/CD Pipeline — Detailed Flow

```
Push to main
     │
     ▼
┌─────────────┐    ┌──────────────┐    ┌──────────────┐
│ Build & Test │───►│ Security     │───►│ Push to ACR  │
│              │    │ Scan (Trivy) │    │              │
│ - docker     │    │              │    │ - tag with   │
│   build      │    │ - fail on    │    │   commit SHA │
│ - pytest     │    │   CRITICAL   │    │              │
│ - lint       │    │              │    │              │
└─────────────┘    └──────────────┘    └──────┬───────┘
                                              │
                                              ▼
                   ┌──────────────┐    ┌──────────────┐
                   │ Verify       │◄───│ Deploy to    │
                   │              │    │ AKS          │
                   │ - health     │    │              │
                   │   check      │    │ - kubectl    │
                   │ - smoke test │    │   apply      │
                   │              │    │              │
                   └──────────────┘    └──────────────┘
```

### Observability Stack Detail

Deployed once by Platform Team, shared by all services:

- **Prometheus (via kube-prometheus-stack Helm chart)**
  - Auto-discovers services via ServiceMonitor CRDs
  - Every golden-path service includes a ServiceMonitor
  - Scrapes /metrics endpoint (exposed by FastAPI app using prometheus_client)
  - Pre-configured alerting rules for RED metrics (Rate, Errors, Duration)

- **Grafana**
  - Pre-built dashboard template for every golden-path service
  - Shows: request rate, error rate, latency percentiles, pod resource usage
  - Platform-level dashboards: cluster health, namespace resource usage, cost indicators

- **Loki (via Grafana Loki)**
  - Collects logs from all pods via Promtail
  - Structured JSON logging from golden-path services
  - Queryable through Grafana (same UI as metrics)

Note: Prometheus has known scaling limits with high-cardinality metrics.
At FinCore's scale this is fine for launch, but the platform team should
plan for Thanos or Grafana Mimir for long-term retention and federation
as the number of services and tenants grows.

### Security Approach

- **Pipeline security:** Trivy scans container images before push. CRITICAL vulnerabilities fail the build.
- **Runtime security:** OPA/Gatekeeper enforces policies (no privileged containers, required labels, resource limits mandatory).
- **Secrets:** Azure Key Vault with CSI driver. Secrets mounted into pods, never in code or env vars.
- **Network:** K8s Network Policies restrict pod-to-pod traffic. Only declared dependencies allowed.
- **Identity:** Azure AD Workload Identity for service-to-Azure authentication. No static credentials.
- **Compliance:** Audit logging via Azure Monitor diagnostic settings. All API calls logged.

Caveat: This security approach is a baseline. For a financial services company,
compliance frameworks (SOC2, ISO 27001, potentially PCI-DSS) have specific controls
that need to be mapped and validated with the Security team and potentially external
auditors. The platform provides the enforcement mechanisms — the policies themselves
need to be defined in collaboration with Security.

---

## Risks & Honest Gaps

### 1. Organizational Resistance (HIGH risk)
Cloud Engineering may see "become a platform team" as losing control or status.
The QA team is essentially being restructured — people will push back.
This is a change management challenge, not a technical one.
**Mitigation:** Involve Cloud Engineering in the platform design from day one.
Frame it as "you're building a product now" not "you're being demoted."
Get leadership sponsorship. For QA, provide clear career paths into automation
or embedded quality roles.

### 2. Timeline Pressure (HIGH risk)
Building the platform + migrating teams + shipping features + launching in 6 months
is three things competing for the same people's time. The platform team is building
the runway while planes are already taking off.
**Mitigation:** Don't aim for all 17 teams at launch. Target 5-8 teams on the
golden path by launch, the rest migrate in Phase 3 and post-launch. Be explicit
about this with leadership.

### 3. The "Two Trains" Problem (MEDIUM risk)
During transition, some teams are on the old process (manual QA, Cloud Eng deploys)
and some on the golden path. Two deployment models running simultaneously is messy
and doubles operational overhead temporarily.
**Mitigation:** Pick pilot teams carefully — willing, capable, not on the critical
path for launch. Get them stable before onboarding the next wave.

### 4. Single-Tenancy Cost Bomb (HIGH risk — not solved by IDP)
We are explicitly NOT solving multi-tenancy for launch. Cloud costs will continue
to rise linearly as customers onboard. Finance won't be happy.
**Mitigation:** Be upfront. The IDP improves operational efficiency and deployment
speed but does not fix the architecture. Multi-tenancy is a product architecture
decision that needs its own workstream. Propose it as a post-launch priority
with a clear business case (cost per customer today vs. multi-tenant target).

### 5. Not Every Service Fits the Golden Path (MEDIUM risk)
Existing services that predate the platform, legacy components, edge cases —
they won't all fit the template. Teams with these services will still need
support from the platform team.
**Mitigation:** Accept this. The golden path covers new services and services
that can be migrated. For the rest, provide a "supported but manual" path
and migrate them over time. Don't let perfect be the enemy of good.

### 6. Developer Skill Gap (MEDIUM risk)
"You own your service now" assumes developers can read Grafana dashboards,
debug failing pods, and understand pipeline outputs. Not all of them can today.
**Mitigation:** The Facilitating interaction mode exists for this. Pair platform
engineers with product teams during onboarding. Write good documentation.
Run workshops. Budget time for this — it's not free.

### 7. Security Is Sketched, Not Proven (MEDIUM risk)
"OPA + Trivy + Key Vault" is a tooling answer. Financial compliance needs
specific controls mapped to specific frameworks. We haven't done that mapping.
**Mitigation:** Flag this early. The platform provides the enforcement layer,
but the actual policies need to come from the Security team and compliance
requirements. This is a collaboration workstream, not something the platform
team does alone.

---

## Phased Rollout — 6-Month Plan

### Phase 1: Foundation (Month 1-2)
- Deploy AKS cluster with Terraform
- Set up observability stack (Prometheus, Grafana, Loki)
- Create golden-path template repo
- Build CI/CD pipeline in GitHub Actions
- Migrate 2-3 pilot services from early-adopter teams (Collaboration mode)
- Platform team formed from Cloud Engineering
- Security team begins defining policies for the platform

### Phase 2: Adoption (Month 3-4)
- Onboard 5-8 product teams (Facilitating mode)
- QA engineers begin embedding in product teams
- Automated testing integrated into pipelines
- Security policies (OPA) enforced in staging, warning in production
- Cost tagging and resource limits enforced
- Service-specific Terraform modules available (database, cache, storage)

### Phase 3: Launch & Stabilize (Month 5-6)
- 5-8 teams deploying through IDP (X-as-a-Service mode)
- Remaining teams continue migration (realistic: not all 17 by launch)
- Security policies enforced in production
- Performance optimization and cost tuning
- Platform team runs on product cadence with backlog
- Multi-tenant architecture design begins (for post-launch)

### Post-Launch Roadmap
- Complete migration of remaining teams to golden path
- Backstage developer portal for service catalog and self-service UI
- Multi-tenancy migration (namespace-based → application-level)
- Service mesh (if needed for inter-service security/observability)
- Disaster recovery and multi-region deployment
- FinOps dashboard with per-team cost visibility
- Thanos/Mimir for long-term metrics retention

---

## Technology Choices — Decision Matrix

| Component | Choice | Why | Alternatives Considered |
|---|---|---|---|
| Runtime | AKS | Compliance controls, policy enforcement, K8s ecosystem, no vendor lock-in. Developers never touch K8s — IDP abstracts it. | Azure Container Apps (simpler but less control, vendor lock-in) |
| CI/CD | GitHub Actions | Simple, self-contained with source code, widely adopted. Concept is tool-agnostic. | Azure DevOps, GitLab CI |
| IaC | Terraform | Already used at FinCore, cloud-agnostic, mature ecosystem | Bicep (Azure-native), Pulumi |
| Container Registry | ACR | Native AKS integration, geo-replication, vulnerability scanning | Docker Hub, GitHub Container Registry |
| Observability | Prometheus + Grafana + Loki | Open source, K8s-native, no vendor lock-in, cost-effective | Azure Monitor (simpler but vendor lock-in, less K8s-native) |
| Secrets | Azure Key Vault + CSI Driver | Azure-native, auditable, no static credentials | HashiCorp Vault |
| Policy | OPA/Gatekeeper | K8s-native policy enforcement, industry standard | Azure Policy for AKS, Kyverno |
| Security Scanning | Trivy | Open source, fast, integrates in CI/CD pipeline | Snyk, Aqua |
| Packaging | Plain K8s manifests (demo), Helm (at scale) | Plain manifests for transparency in demo. Helm for templating across 17 teams and multiple environments. | Kustomize |

---

## What the Demo Will Show

A single end-to-end flow:

1. **The golden-path template repo** — show the structure, explain what each part does
2. **Push a code change** — a small feature addition to the FastAPI sample service
3. **Pipeline runs automatically** — show GitHub Actions: build, test, scan, push, deploy
4. **Service is live on AKS** — hit the API endpoint, show it works
5. **Observability** — switch to Grafana, show metrics flowing from the service, show logs in Loki
6. **The story:** "A developer just shipped a feature to production in under 5 minutes with zero tickets, zero handoffs, and full observability. This is what every team at FinCore gets on day one."
