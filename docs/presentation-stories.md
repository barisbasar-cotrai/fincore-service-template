# Presentation Stories & Key Concepts

## The Core Narrative

FinCore built microservices but didn't build the platform underneath them. They have 17 teams trying to push through one Cloud Engineering team. The fix isn't more people or more process — it's a platform that turns manual, ticket-based workflows into self-service capabilities. Cloud Engineering evolves from doing the work to building the tools. Developers get autonomy back. Deployments get fast and consistent. Observability comes built-in. And because everything goes through the same golden path, security and compliance become enforceable by default rather than a checklist someone forgets.

## Evolution Story (for context-setting in the presentation)

- Sysadmin/Ops era → DevOps era → DevOps-at-scale problem → Platform Engineering
- DevOps worked great for 3-5 teams. At 17 teams, every team can't be expected to deeply understand K8s, Terraform, networking, security, monitoring, and CI/CD.
- Platform Engineering: a dedicated team builds a self-service product that abstracts infrastructure complexity for developers.
- Key difference from old ops: old model does things FOR developers. Platform engineering builds tools that ENABLE developers to do things themselves.

## IDP — Five Layers

1. **Developer Control Plane** — what devs see (portal, CLI, template repos)
2. **Integration and Delivery Plane** — CI/CD (build, test, push, deploy)
3. **Resource Plane** — infrastructure provisioning via IaC
4. **Monitoring and Observability Plane** — logs, metrics, traces baked in by default
5. **Security Plane** — policy enforcement, secrets, compliance scanning

## Platform Operating Model — Three Components

### Team Topologies (Skelton & Pais)
- **Stream-aligned teams** = FinCore's 17 product teams. Deliver value to users. Own services end-to-end.
- **Platform team** = what Cloud Engineering must become. Builds/maintains the IDP. Developers are their customers.
- **Enabling team** = helps other teams adopt new capabilities. Temporary during transition.
- **Complicated-subsystem team** = deep specialist knowledge (e.g., Security for financial compliance).

### Interaction Modes
- **X-as-a-Service** — self-service, no tickets. Target state.
- **Collaboration** — platform team works with early adopter product teams to co-build platform features.
- **Facilitating** — platform team helps product teams adopt the platform (training, pairing, docs).

### Platform as a Product
- Developers are customers, not ticket submitters
- Gather feedback, prioritize, measure adoption
- Build the thinnest useful layer first, iterate based on real needs
- Prevents over-engineering something nobody uses

## Golden Paths

Opinionated, pre-built, supported ways to do common tasks:
- New service → clone template (Dockerfile, Terraform, pipeline, metrics, dashboards all included)
- Need a database → add a block to infrastructure config, pipeline provisions it
- Deploy to prod → merge to main, pipeline handles the rest

"Golden" not "mandatory" — respects developer autonomy while providing guardrails. 90% of teams will use the path because it's the fastest, easiest option.

### What golden paths solve at FinCore:
- "Setting up new services is too complex" → golden path makes it trivial
- "Inconsistent toolchain" → standardizes without mandating
- "Deployments slow and fragile" → tested, automated pipeline included
- "Developers feel blocked" → self-service, no tickets

---

# FinCore Problem Analysis

## The One-Line Diagnosis

These aren't 7 separate problems — they're all symptoms of one thing: FinCore is operating 17 autonomous teams through a centralized, manual infrastructure model.

## Problem-by-Problem Breakdown

### 1. "Features are delivered too slowly"

**Root cause:** Not slow coding — slow handoffs. Feature flow: dev → wait for sprint end → handoff to QA → manual testing → handoff to Cloud Engineering → deployment. Each handoff is a queue. Each queue adds days or weeks.

**IDP fix:** Automated pipelines with built-in testing. Push → pipeline tests and deploys. No handoffs, no queues.

### 2. "Deployments are slow, fragile, require multiple teams"

**Root cause:** Deployments are manual, cross-team ceremonies. Cloud Engineering is the only team that can push to production. 17 product teams feeding into 1 team = serialized bottleneck.

**IDP fix:** Standardized deployment pipeline in the golden path. Every service deploys the same way, automatically. Cloud Engineering builds the pipeline once; every team uses it.

### 3. "Setting up new services is more complex than expected"

**Root cause:** No standardization. Each team figures out from scratch how to structure a repo, write a Dockerfile, configure Terraform, set up a pipeline. No template, no docs, no paved road.

**IDP fix:** Golden path service template. clone → configure → push → running in production.

### 4. "Observability is limited"

**Root cause:** Observability is an afterthought, not a default. Teams skip it under sprint pressure. No centralized observability stack that services plug into automatically.

**IDP fix:** Every golden-path service gets metrics, logging, and tracing out of the box. Prometheus scrapes automatically, Grafana dashboards are templated, structured logging goes to a central store.

### 5. "Developers feel blocked, dependent on Cloud Engineering"

**Root cause:** The #1 organizational problem. Developers literally cannot deploy or provision infra. The quote: "We can only build code; infra and deployments go through Cloud Engineering." That's not DevOps — that's the old ops model with a new name.

**IDP fix:** Self-service. Developers declare what they need in code, the platform provisions it. Cloud Engineering shifts from "doing" to "enabling."

### 6. "Cloud spend is rising"

**Root cause:** Two factors. (1) Single-tenant architecture — one instance per customer, costs scale linearly. Unsustainable for SaaS. (2) No cost visibility or governance — teams don't see what their services cost.

**IDP fix (partial):** Platform enforces resource limits, provides cost tagging, offers right-sized resource templates. Bigger fix: multi-tenancy — that's a product architecture decision. Recommend in roadmap but acknowledge it's a bigger effort.

### 7. "Security and compliance for SaaS are still unclear"

**Root cause:** Security is a separate team, not integrated into the dev flow. Compliance requirements (data isolation, audit logging, encryption, access controls) haven't been codified into enforceable policies.

**IDP fix:** Shift security left. Bake scanning into the pipeline. Policy-as-code (OPA/Gatekeeper on K8s) enforces compliance automatically. Golden path includes security defaults — container scanning, Key Vault secrets, network policies.

## The Hidden Problem: Single-Tenant Architecture

They mention "currently supports a single tenant per instance" casually, but it's a ticking bomb:
- Cloud costs scale linearly with customers (explains rising costs)
- Every deployment must be repeated per customer (explains slow, fragile deployments)
- Onboarding a new customer is an infrastructure event, not a config change

For the 6-month launch, full multi-tenant rewrite isn't realistic. Propose a roadmap: platform supports multi-tenant deployment patterns, services migrate incrementally after launch.

## Reading the Employee Quotes

| Quote | What it really tells us |
|---|---|
| Cloud Engineer: "Devs don't take responsibility" | Cloud Eng is overwhelmed and blaming devs. But devs can't do infra — they're not empowered to. |
| Sales: "Scope cannot be cut" | Business pressure is real. Platform must enable speed, not add dependency. |
| Eng Manager: "Burnout is real" | Overworking compensates for broken processes. Fix process = fix burnout. |
| Finance: "Cut cloud costs" | Single-tenancy + no governance = cost explosion. |
| QA Lead: "No time to automate" | Vicious cycle — no time to automate because busy testing manually. Break cycle by building test automation into golden path. |
| Developer: "We can only build code" | The smoking gun. Zero developer autonomy over their own services. |
