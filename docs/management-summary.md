# FinCore SaaS Platform — Assessment & Recommendation

*Prepared for FinCore Leadership | [Your Name] | Xebia*

---

## Situation

FinCore has committed to launching a SaaS platform in six months. After nearly a year of development with 20 teams, delivery remains slow, deployments are fragile, and cloud costs are rising. Previous attempts at this initiative have not succeeded. Leadership is right to be concerned.

## Diagnosis

After reviewing the current state, the core issue is not technical capability — FinCore has competent engineers and reasonable technology choices. The issue is structural: 17 product teams are funneling all infrastructure and deployment work through a single Cloud Engineering team. This creates a bottleneck that slows everything down.

Developers cannot deploy their own services. QA is manual and sequential. Every infrastructure change requires a ticket. The result: handoffs, queues, and waiting — none of which produce customer value.

Additionally, the current single-tenant-per-instance architecture means cloud costs will scale linearly with every new customer onboarded. This is manageable for launch but becomes unsustainable at scale.

## Recommendation: Internal Developer Platform

We recommend building an Internal Developer Platform (IDP) — a self-service layer that gives product teams the ability to build, deploy, and monitor their services without depending on Cloud Engineering for every change.

The approach rests on three pillars:

1. **Golden Path** — A standardized service template with CI/CD pipeline, infrastructure-as-code, security scanning, and observability pre-configured. New services go from code to production in minutes, not days. Existing services migrate incrementally.

2. **Platform Team** — Cloud Engineering evolves from a ticket-based operations team to a product team that builds and maintains the platform. Developers become their customers. The Security team embeds compliance policies directly into the platform as automated guardrails.

3. **Shift Left** — Testing, security scanning, and quality gates move into the automated pipeline. The separate QA team transitions into embedded quality roles within product teams, focusing on test automation instead of manual regression.

**Technology:** Azure Kubernetes Service, Terraform, GitHub Actions, Prometheus/Grafana. All open source, no vendor lock-in.

## Expected Outcomes

| Metric | Current | Target (6 months) |
|---|---|---|
| Deployment lead time | Days to weeks | Under 30 minutes |
| New service onboarding | Weeks | Less than 1 day |
| Deployment frequency | End of sprint | Multiple per day per team |
| Cloud cost visibility | None | Per-team cost tracking |

## Timeline

- **Month 1-2:** Platform foundation — AKS cluster, CI/CD pipeline, observability stack. Pilot with 2-3 early adopter teams.
- **Month 3-4:** Onboard 5-8 teams. Automated testing and security policies in staging.
- **Month 5-6:** Stabilize for launch. Not all 17 teams will migrate by launch — that's realistic, not a failure.

## Risks We Must Be Honest About

- Organizational change is harder than the technology. Cloud Engineering and QA will need leadership support through the transition.
- Single-tenant architecture is not solved by the IDP. We recommend a separate multi-tenancy workstream post-launch to control long-term cloud costs.
- Building the platform and shipping features compete for the same people's attention. Pilot team selection and phased adoption are critical.
