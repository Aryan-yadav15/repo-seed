---
description: Plan a feature before coding — reuse first, new code only where missing
argument-hint: <feature description>
---
Plan feature: $ARGUMENTS

1. Find it in `docs/PLAN.md`; if absent, propose where it fits and whether it's in scope.
2. Read relevant ADRs and INCIDENTS Lessons.
3. List what already exists that it can reuse (use cases, gateways, components).
4. List what's missing: new domain models, use cases, gateway domains/providers, screens, endpoints, migrations.
5. Give a step-by-step implementation plan in small commits, each with its tests, the feature flag name, and an acceptance test ("done when…").
6. Flag risks (legal, platform policy, cost, unofficial APIs).
Wait for my OK before coding. Then implement, run architecture-reviewer (and ui-reviewer for UI) before each commit, and update PROGRESS.
