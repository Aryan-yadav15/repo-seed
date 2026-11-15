---
description: Add a provider to a gateway domain (CLAUDE.md §3, §14)
argument-hint: <domain> <provider-name> [docs-url]
---
Add provider: $ARGUMENTS

Follow CLAUDE.md §3 exactly. Read INCIDENTS Lessons for this domain first.
1. If the domain/gateway doesn't exist yet, stop and propose it (domain models, provider interface, gateway, config) — wait for OK.
2. Create the provider file in the domain's private providers package; declare capabilities honestly (quota, cost, official/unofficial).
3. Create its mapper (raw → domain). No provider-specific fields in domain models.
4. Recorded fixtures + run the shared contract suite against it + mapper tests.
5. Add to config priority list (default lowest) with timeout, rate limit, breaker settings.
6. Verify: no caller files changed; boundary linter passes; tests pass.
7. Update PROGRESS Inventory.
