# Presentation Slides — FinCore IDP

## Google Slides Setup

**Theme colors:**
- Primary (headings, accents): #891F7A (Velvet Purple)
- Dark backgrounds: #150027
- Light background: #FAF8F8 or white
- Text: #150027 (dark) or white (on dark slides)
- Accent: #CB2EBA (lighter purple for highlights)

**Font:** Inter or Work Sans (closest to Xebia's Suisse Intl)
- Slide titles: Bold, 36-40pt
- Body text: Regular, 18-22pt
- Small labels: Medium, 14-16pt

**Layout rules:**
- Lots of white space — don't crowd slides
- One idea per slide
- Use dark background slides (#150027) for section transitions
- Use white/light slides for content
- Minimal bullet points — prefer visuals and short statements

---

## SLIDE 1 — Title
**Layout:** Dark background (#150027), Xebia logo top-right if available

```
FinCore SaaS Platform
Internal Developer Platform — Strategy & Demo

[Your Name]
Platform Architect | Xebia
[Date]
```

**Speaker notes:** Introduce yourself briefly. "I'm [name], I've been asked to assess FinCore's current platform situation and propose a path forward for the SaaS launch."

---

## SLIDE 2 — Agenda
**Layout:** Light background, simple list

```
Agenda

1. What I found
2. Why it's happening
3. The platform approach
4. How it works (architecture)
5. Live demo
6. Roadmap & risks
```

**Speaker notes:** "I'll start with my understanding of where FinCore is today, then walk through my diagnosis, the proposed solution, and show you a working prototype."

---

## SLIDE 3 — The Situation
**Layout:** Light background. Key facts as large statements, not bullets.

```
The Situation

20 teams. Nearly a year of development.
6 months to launch. Previous attempts failed.

"Features are delivered too slowly."
"Deployments are slow, fragile, and require multiple teams."
"Developers feel blocked by processes."
"Cloud spend is rising."
```

**Speaker notes:** "Let me start with what I understand about where FinCore is. You have 20 teams, you've been building for almost a year, you have a hard deadline in 6 months, and this has failed before. Leadership sees slow delivery, fragile deployments, rising costs, and developers who feel stuck. These are serious problems, but they're not random — they have a common root cause."

---

## SLIDE 4 — What I Heard
**Layout:** Light background. Quote cards — each quote in a styled box with the role below.

```
What I heard from the teams

┌─────────────────────────────────────────────────────┐
│ "We can only build code; infra and deployments      │
│  go through Cloud Engineering."          — Developer │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ "Developers are not taking responsibility and rely   │
│  on us for every infra change."    — Cloud Engineer  │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ "We don't have time to automate tests because of    │
│  manual sprint pressure."              — QA Lead     │
└─────────────────────────────────────────────────────┘
```

**Speaker notes:** "These quotes tell me a lot. The developer says they can only write code — everything else is someone else's job. The cloud engineer says developers don't take responsibility — but they can't, they're not empowered to. The QA lead is stuck in a cycle — too busy testing manually to ever automate. These aren't bad people. They're stuck in a broken structure."

---

## SLIDE 5 — The Diagnosis
**Layout:** Dark background (#150027), white text. One big statement centered.

```
The problem is not technical capability.

The problem is structural:
17 teams funneling through 1.
```

**Speaker notes:** "This is the core of my assessment. FinCore has good engineers, reasonable technology choices. The problem is that 17 product teams depend on a single Cloud Engineering team for every deployment, every infrastructure change, every environment setup. That's a bottleneck. And no amount of overtime or funding will fix a bottleneck — you have to remove it."

---

## SLIDE 6 — The Current Flow
**Layout:** Light background. Simple flow diagram (use shapes in Google Slides).

```
How a feature ships today

Developer → [wait for sprint end] → QA Team → [manual testing]
→ Cloud Engineering → [deploy to production]

3 handoffs. 3 queues. Weeks of waiting.
```

**Speaker notes:** "Here's what the delivery flow actually looks like. A developer finishes a feature, waits for the sprint to end, hands it to QA for manual testing, then QA passes it to Cloud Engineering for deployment. Every arrow here is a queue. Every queue adds days. None of this waiting produces value for customers."

---

## SLIDE 7 — The Target Flow
**Layout:** Light background. Simplified flow showing the IDP approach.

```
How a feature should ship

Developer → push to main → [automated pipeline] → production

1 action. Minutes, not weeks.
Pipeline handles: test → scan → build → deploy → monitor
```

**Speaker notes:** "This is what the target looks like. A developer pushes code. An automated pipeline tests it, scans it for security vulnerabilities, builds a container, deploys it, and starts monitoring it. No handoffs. No tickets. No waiting for another team. I'll show you this working live in a few minutes."

---

## SLIDE 8 — What is an IDP
**Layout:** Light background. Simple definition + the five layers.

```
Internal Developer Platform

A self-service layer that gives product teams the ability to
build, deploy, and monitor their services independently.

┌─────────────────────────────────────────┐
│  Developer Experience (templates, docs)  │
├─────────────────────────────────────────┤
│  Integration & Delivery (CI/CD)          │
├─────────────────────────────────────────┤
│  Resource Plane (infrastructure as code) │
├─────────────────────────────────────────┤
│  Observability (metrics, logs, alerts)   │
├─────────────────────────────────────────┤
│  Security (policy, scanning, secrets)    │
└─────────────────────────────────────────┘
```

**Speaker notes:** "An IDP is the collection of tools and automation that developers interact with to ship software. It's organized in five layers. At the top, developers see templates and documentation. Underneath, there's a CI/CD pipeline, infrastructure provisioning, observability, and security — all automated, all self-service. The key idea: Cloud Engineering stops doing the work for developers, and instead builds the platform that lets developers do it themselves."

---

## SLIDE 9 — Platform Operating Model
**Layout:** Light background. Before/after diagram.

```
Platform Operating Model

BEFORE                              AFTER
─────────                           ─────────
17 Product Teams                    17 Stream-Aligned Teams
      │ tickets                           │ self-service
      ▼                                   ▼
Cloud Engineering ← bottleneck      Platform Team
QA Team           ← bottleneck        (builds & maintains IDP)
Security Team                       Security → embeds policy in platform
                                    QA → embedded in product teams
```

**Speaker notes:** "Here's the organizational change. Today, Cloud Engineering is a ticket queue. In the target state, they become a Platform Team — their product is the platform, their customers are the developers. QA engineers move into product teams and focus on test automation. Security embeds their compliance requirements as automated policies in the platform. This is based on Team Topologies — a well-established framework for organizing engineering teams."

---

## SLIDE 10 — Golden Path
**Layout:** Light background. Show the template repo structure.

```
The Golden Path

"Here's the fast, supported, compliant way to ship a service."

Clone the template → configure → push → running in production

Template includes:
  App scaffold          (FastAPI / your framework)
  Dockerfile            (multi-stage, secure)
  CI/CD pipeline        (test, scan, build, deploy)
  K8s manifests         (deployment, service, monitoring)
  Grafana dashboard     (pre-built, auto-provisioned)
  Observability         (metrics + logs from day one)
```

**Speaker notes:** "The golden path is an opinionated, pre-built template for how to create and ship a service. A developer clones the template, configures their service name, writes their application code, and pushes. Everything else — the pipeline, the infrastructure, the monitoring — is already wired up. It's not mandatory — teams can deviate if they have a reason — but 90% of the time, the golden path is the fastest and easiest option. This directly addresses the complaint that setting up new services is too complex."

---

## SLIDE 11 — Architecture Overview
**Layout:** Light background. The architecture diagram from docs/architecture.md.
Recreate using Google Slides shapes or paste as an image.

```
[Use the IDP architecture diagram from docs/architecture.md]

Developer Experience → Integration & Delivery → Resource Plane
                                                      ↓
                                              Observability Plane
                                                      ↓
                                                Security Plane
```

**Speaker notes:** "Here's how the layers map to actual technology. Developers interact with GitHub and the template repo. GitHub Actions handles CI/CD. Terraform provisions Azure resources — AKS for container orchestration, ACR for image storage. Prometheus and Grafana provide observability. OPA/Gatekeeper enforces security policies. Every piece is open source, no vendor lock-in. If FinCore ever needs to move off Azure, the application layer — Kubernetes manifests, Helm charts, Prometheus configs — is portable."

---

## SLIDE 12 — Technology Decisions
**Layout:** Light background. Clean table.

```
Technology Choices

Component        Choice                    Why
─────────        ──────                    ───
Runtime          AKS (Kubernetes)          Compliance control, portability, no lock-in
CI/CD            GitHub Actions            Simple, self-contained, tool-agnostic concept
Infrastructure   Terraform                 Already used at FinCore, cloud-agnostic
Observability    Prometheus + Grafana      Open source, K8s-native, cost-effective
                 + Loki
Security         OPA/Gatekeeper + Trivy    Policy-as-code, pipeline scanning
Secrets          Azure Key Vault           Azure-native, auditable

Design principle: open source, portable, no vendor lock-in.
```

**Speaker notes:** "Every choice here is deliberate. We picked AKS over Azure Container Apps because a financial services company needs fine-grained security controls — network policies, pod security, policy enforcement — that only Kubernetes gives you. But developers never touch Kubernetes directly. The platform abstracts it completely. Terraform is already in use at FinCore. Prometheus and Grafana are industry standard and free. The entire stack can run on any cloud provider."

---

## SLIDE 13 — Phased Rollout
**Layout:** Light background. Timeline as a horizontal bar or roadmap.

```
6-Month Rollout

Month 1-2: FOUNDATION
  Platform infrastructure (AKS, CI/CD, observability)
  Golden path template
  Pilot with 2-3 teams

Month 3-4: ADOPTION
  Onboard 5-8 teams
  Automated testing in pipelines
  Security policies in staging

Month 5-6: LAUNCH
  Stabilize for launch
  Security policies in production
  Remaining teams continue migration

⚠ Realistic: 5-8 teams on golden path at launch, not all 17.
  That's a success, not a failure.
```

**Speaker notes:** "Six months is tight. Here's how I'd phase it. First two months: build the platform, get the golden path working, pilot with two or three willing teams. Months three and four: onboard the next wave, integrate testing and security automation. Months five and six: stabilize for launch. I want to be direct — not all 17 teams will be on the platform by launch. Targeting 5 to 8 is realistic and achievable. Forcing all 17 would risk the quality of both the platform and the product."

---

## SLIDE 14 — Demo Introduction
**Layout:** Dark background (#150027), white text. Simple statement.

```
Let me show you.

A developer ships a feature to production
in under 5 minutes. No tickets. No handoffs.
Full observability from the moment it deploys.
```

**Speaker notes:** "Enough slides. Let me show you a working prototype of what I've been describing." — Then switch to the live demo. Follow the demo script from the README.

---

## [LIVE DEMO — ~8 minutes]
## Follow the demo script in README.md

---

## SLIDE 15 — Risks
**Layout:** Light background. Honest, no sugarcoating.

```
What could go wrong

HIGH   Organizational resistance
       Cloud Engineering and QA face real change.
       Needs leadership sponsorship and clear career paths.

HIGH   Timeline vs. reality
       Platform build competes with feature delivery
       for the same people's time.

HIGH   Single-tenant cost bomb (not solved by IDP)
       Multi-tenancy is a product architecture decision.
       Recommend as a post-launch workstream.

MEDIUM Developer skill gap
       "You own your service" needs training and support.
       Platform team facilitates during transition.

MEDIUM Security is a starting point, not complete
       Financial compliance needs mapping to specific frameworks.
       Collaboration with Security team required.
```

**Speaker notes:** "I don't want to oversell this. Here are the real risks. The biggest one isn't technical — it's organizational. Cloud Engineering is being asked to change their identity. QA is being restructured. People will push back, and that's natural. This needs active leadership support. Second, we're building the platform while product teams keep shipping features. That tension is real. Third — and this is important — the IDP does not solve the single-tenant architecture. Cloud costs will keep rising as you onboard customers. Multi-tenancy needs its own workstream after launch."

---

## SLIDE 16 — Expected Outcomes
**Layout:** Light background. Table with before/after.

```
What changes

                        Today              6 Months
────────────────────────────────────────────────────
Deployment lead time    Days to weeks      < 30 minutes
New service setup       Weeks              < 1 day
Deployment frequency    End of sprint      Multiple per day
Developer autonomy      Blocked            Self-service
Observability           Limited            Built-in by default
Security compliance     Unclear            Automated guardrails
Cloud cost visibility   None               Per-team tracking
```

**Speaker notes:** "If we execute this well, here's what FinCore looks like in six months. Deployments go from days to minutes. New services go from weeks to hours. Developers can ship independently. Every service has observability from day one. Security is automated, not a checklist. And you'll actually know what things cost."

---

## SLIDE 17 — Summary & Next Steps
**Layout:** Dark background (#150027), white text.

```
Summary

The problem:  17 teams, 1 bottleneck.
The fix:      Self-service platform, not more process.
The approach: Golden path + platform team + shift left.
The proof:    It works. You just saw it.

Next steps:
  1. Align on the platform team composition
  2. Select 2-3 pilot teams
  3. Start building — month 1 begins now
```

**Speaker notes:** "To close — FinCore doesn't have a technology problem, it has a structural one. The IDP removes the bottleneck by turning manual, ticket-based workflows into self-service. You saw a developer ship a feature in minutes with no handoffs and full observability. The platform approach is proven across the industry. The next step is to form the platform team, pick the pilot teams, and start building. I'm happy to take questions."

---

## BACKUP SLIDES (if asked about specific topics)

### BACKUP — Multi-tenancy roadmap

```
Multi-Tenancy Migration (post-launch)

Phase 1: Namespace isolation (quick win, minimal code change)
Phase 2: Database-level tenant isolation
Phase 3: Application-level multi-tenancy for core services

Business case: reduces cloud cost from O(n) per customer
to near-constant operational cost at scale.
```

### BACKUP — Why not Azure Container Apps?

```
AKS vs Azure Container Apps

Considered ACA — simpler, serverless, scales to zero.

Chose AKS because:
- Financial compliance needs fine-grained security controls
- Network policies, pod security, OPA/Gatekeeper
- Entire observability ecosystem is K8s-native
- Portable: workloads run on any cloud
- Developers never touch K8s — IDP abstracts it

ACA would be a valid choice for less regulated industries.
```

### BACKUP — Backstage / Developer Portal

```
Developer Portal (future roadmap)

Current MVP: template repo + pipeline + docs
Next phase: Backstage (open source, Spotify)

What it adds:
- Service catalog (who owns what)
- Self-service UI for creating services
- Documentation hub
- Plugin ecosystem

Not needed for launch. Becomes valuable
when the platform serves 10+ teams.
```

### BACKUP — Cost estimate

```
Platform running cost (approximate)

AKS (2x B2s_v2 nodes)     ~$60/month
ACR (Basic)                ~$5/month
Log Analytics              ~$10/month
Load Balancer + IP         ~$20/month
Prometheus/Grafana/Loki    runs on AKS (no extra cost)
──────────────────────────────────────
Total                      ~$95/month for dev environment

Production: scale nodes, add environments.
Still far cheaper than current per-tenant deployment model.
```
