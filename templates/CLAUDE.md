# CLAUDE.md — {{PROJECT_NAME}} Engineering Guide

> Read this before writing any code. It is the law of this repo. This file is **how** we build.
> Sub-folders have their own `CLAUDE.md` with stack-specific rules; both apply.

## Project memory files
- Product plan: @docs/PLAN.md
- UI rules: @docs/DESIGN.md (mandatory for any UI / animation work — delete this line if no UI)
- Status: @docs/PROGRESS.md — read at session start; update at session end and when a task changes state
- Incidents: @docs/INCIDENTS.md — read "Lessons" before touching a listed area; log any non-trivial breakage
- Decisions: `docs/adr/` — read the relevant ADR before changing anything it covers

**Session ritual:** start → read PROGRESS "Current Snapshot" + INCIDENTS "Lessons" → work in small commits → end → Session Log entry, update Snapshot/Inventory, log incidents, write ADRs for decisions.

---

## 0. Why this codebase is strict
Uniformity beats cleverness. Every module, provider and feature follows one repeatable recipe so that humans and AI agents can extend it safely. **If a change makes the system less uniform, it is wrong even if it works.**

### 0.1 Engineering principles
- **SOLID:** single responsibility; open for extension (new provider/feature) without modifying callers; depend on interfaces; small focused interfaces.
- **DRY, but no premature abstraction:** extract on the 2nd real duplication.
- **KISS / YAGNI:** simplest design that meets today's need + documented extension points.
- **Composition over inheritance.** At most one level of abstract base class.
- **Immutability by default** in public APIs and domain models.
- **Dependency injection:** constructor injection only; wiring in one place per app; no service locators or stateful singletons.
- **Pure core, impure edges:** domain logic deterministic (inject `Clock`, `IdGenerator`); I/O only in providers, repositories, platform adapters.
- **Fail fast at boundaries:** validate where data enters (API, user input, files, AI output, provider responses); trust typed data inside.
- **Explicit over implicit:** no magic strings — ids, events, permissions are enums/constants.
- **Boy-scout rule:** leave touched code cleaner; refactors in separate commits.

### 0.2 Design patterns we use
| Pattern | Where |
|---|---|
| Facade | Gateways — one entry over many providers |
| Adapter | Providers + mappers — wrap each external API into our interface |
| Strategy | Gateway policies — provider selection & fallback |
| Circuit breaker | Per provider in every gateway |
| Repository | Persistence behind interfaces |
| Registry | Plugin-like collections (providers, handlers, features) |
| Observer / pub-sub | Events between modules |
| Use case (interactor) | One business action per class/function |

---

## 1. Repo Layout
{{REPO_LAYOUT — 2–3 levels, one top-level folder per deployable part (e.g. app/, server/, web/), plus:}}
```
docs/        PLAN · DESIGN · PROGRESS · INCIDENTS · adr/
schemas/     shared contracts (JSON Schema / OpenAPI) — single source of truth
scripts/     one-off tools
.claude/     commands · agents · hooks · settings.json
.github/     workflows/
```

---

## 2. Layering & Dependency Rule
```
presentation (UI / API routes) → application (use cases / services) → domain ← data/integrations ← core
```
- Dependencies point **inward**. `domain` imports nothing from frameworks, UI, data or network.
- Presentation is thin: parse input → call a use case/service → render/return. No business logic.
- Use cases call **gateways/repositories**, never providers or raw clients.
- **Providers are private** to their integration package. Enforce with language visibility + an import-boundary linter in CI.

---

## 3. Provider → Gateway Pattern (the "middle layer")

Every external or swappable capability (third-party APIs, AI models, payments, maps, storage, email, push, scraping…) follows exactly this shape:
```
caller ──► Gateway (one per domain) ──► Provider A / B / C
             └─ selection · fallback · cache · rate limit · retry · timeout
                · circuit breaker · mapping to domain models · logging · metrics · call budget
```
### 3.1 Rules
1. One **Gateway** per domain; one **Provider interface** per domain next to it.
2. Gateways accept and return **domain models only** — never provider JSON.
3. One **mapper** per provider (raw → domain). Mapping lives nowhere else.
4. Providers declare **capabilities** (features, quotas, cost, official/unofficial).
5. Selection/fallback/merge strategy is **config**, not code.
6. Callers never know which provider answered (except `meta.provider` for logs).
7. **Adding a provider = 1 provider file + 1 mapper + 1 config line + tests. No caller changes.**
8. Build the gateway even with one provider — the second must be a drop-in.

### 3.2 Reference shape (adapt syntax to the stack)
```
interface XProvider { name; capabilities; search(query: XQuery): List<XResult>; health(): Bool }

class XGateway(providers, policy, cache, limiter, breaker, logger) {
  search(query): Result<List<XResult>> {
    cached? → return ok(cached, provider="cache")
    for p in policy.order(providers, need):
      skip if limiter denies or breaker open
      try with timeout → cache → return ok(result, provider=p.name)
      catch ProviderError → log, breaker.record, continue
    stale cache? → return ok(stale, isStale=true)
    return fail(AllProvidersFailed(domain, causes))
  }
}
```
### 3.3 Domains in this project
{{GATEWAY_TABLE — | Domain | Gateway | Providers (priority) | Free? / Official? |}}

---

## 4. Feature Modules
- One folder per feature (vertical slice) inside the presentation layer; shared logic goes down a layer, never sideways between features.
- A feature talks to other features only through use cases or events — never by importing their internals.
- New features ship behind a feature flag (default off) until verified.

---

## 5. Contracts & Schemas
- Shared data contracts live in `schemas/` (JSON Schema / OpenAPI) and are the single source of truth; client models are **generated**, never hand-written twice.
- Validate against the schema on both sides of every boundary.
- Generated files are never hand-edited; CI fails if they drift from their source.

---

## 6. Naming Conventions
| Thing | Convention | Example |
|---|---|---|
| Types/classes | PascalCase, no `I` prefix | `PaymentGateway` |
| Implementations | `<Source><Role>` | `StripePaymentProvider` |
| Functions/vars | language idiom (camelCase / snake_case), verbs for actions | `searchFlights` / `search_flights` |
| Constants | UPPER_SNAKE | `MAX_RETRY_COUNT` |
| Use cases | `<Verb><Noun>UseCase` / `<Domain>Service` | `CreateOrderUseCase` |
| DTOs | `<Provider><Name>Dto` | `StripeChargeDto` |
| Mappers | `<Provider>Mapper` | `NominatimMapper` |
| Tests | mirror source path, `<Subject>Test` / `test_<subject>.py` | |
- Units in names: `timeout_s`, `distance_m`, `price_minor`, `duration_ms`.
- Booleans start with `is/has/can/should`.
- No abbreviations except well-known (`id`, `url`, `api`, `ui`, `db`).
- Time: store UTC, timezone-aware; display in user's zone.
- Money: integer minor units (paise/cents) + currency code; never floats.

---

## 7. Errors & Results
- Business and integration code returns a typed **Result** (`Ok(value, meta)` | `Err(error)`); no throwing across layers.
- Typed errors: `InvalidInput`, `NotFound`, `PermissionDenied`, `RateLimited`, `Timeout`, `ProviderError`, `AllProvidersFailed`, `Conflict`.
- Catch exceptions at the edge (provider/adapter), convert, log with context. Never swallow silently.
- UI/API map error types to friendly messages / status codes in one place.

---

## 8. Configuration & Secrets
- Behavior (provider order, timeouts, TTLs, quotas, flags) in config files + env; never hard-coded.
- Secrets only from env / local untracked files. Never committed, never shipped in client bundles, never logged.
- `.env.example` lists every variable; apps fail at **startup** if a required one is missing.

---

## 9. Concurrency & Performance
- Async/non-blocking I/O; no blocking the UI/main thread; CPU-heavy work in worker pools/background jobs.
- Every external call has timeout, retry with backoff + jitter (idempotent only), cache TTL and a call budget.
- Performance budgets are defined per part (startup time, p95 latency, bundle/APK size) and tracked in CI.

---

## 10. AI / LLM Usage (if applicable)
- All model calls go through an `LlmGateway`.
- Every call uses a **response schema**; validate output; one retry with the validation error, then fail.
- Prompts are versioned files (`prompts/<name>.v1.md`), never inline strings.
- Untrusted content is passed as clearly delimited data; model output never triggers side effects without validation/confirmation.
- Log prompt version, provider, latency, tokens — never full personal content.

---

## 11. Testing
- **Pyramid:** many unit tests (domain, use cases, mappers), fewer integration tests (gateways, DB, API), few end-to-end.
- Providers: shared **contract test suite** run against every provider with recorded fixtures.
- Gateways: fallback order, cache hit, rate-limit skip, breaker open, timeout, all-fail.
- No real network in unit tests. Prefer **fakes** (`FakeXProvider`) over mocks.
- UI: screenshot tests for components (light/dark/large text) + a few flow tests.
- Coverage target for domain + application + gateways: ≥ 85%.
- Every bug fix ships with a regression test.

---

## 12. Code Quality Gates
- `make check` runs everything: format check, lint, strict types, import boundaries, `scripts/check-rules.sh` and tests, for every part. Pre-commit, CI and the Stop hook all run it — a turn doesn't end red.
- **A rule a machine can decide is a check, not a reminder.** Each part's `CLAUDE.md` lists the lint rule behind each one ("Enforced rules"); this file keeps the why. Every check's failure message names the fix, not just the violation.
- No `TODO` without an issue link (`TODO(#123): …`), no commented-out code, no print debugging — use the logger. All enforced.
- Suppressions (`noqa`, `type: ignore`, `@ts-expect-error`, `eslint-disable`, `@Suppress`…) carry a reason on the same line, and their total can't grow past `.suppressions-baseline`. If a rule is wrong, change the rule in its own commit and say why; never silence it inline to get green. Lint/type configs and the baseline need the user's OK to edit.
- Files ≤ 400 lines, functions ≤ 40 lines unless justified in review.
- Docstrings/KDoc/JSDoc on public APIs explain **why**.

---

## 13. Git & Workflow
- Branches: `feat/…`, `fix/…`, `refactor/…`, `chore/…`. Conventional commits: `feat(payments): add razorpay provider`.
- Small PRs/commits, one concern each. CI green before merge.
- Non-obvious decisions → `docs/adr/NNNN-title.md`.

---

## 14. Recipes for Common Changes
**Add a provider:** provider file + mapper + fixtures + contract tests + config line. No caller changes. (`/new-provider`)
**Add an integration domain:** domain models → provider interface → gateway → first provider → wire in DI → contract suite → expose via use case.
**Add a feature:** plan it (`/plan-feature`) → reuse existing use cases/gateways → new code only where missing → flag → tests → PROGRESS.
**Add a screen:** follow DESIGN.md (`/new-screen`).
**Record a decision:** `/new-adr`.

---

## 15. Resilience
Timeout → retry (backoff + jitter, idempotent only) → circuit breaker → fallback provider → stale cache (`meta.isStale`) → typed error. Optional steps degrade gracefully. Idempotency keys on create endpoints. Background jobs are idempotent and resumable; alerts/notifications are deduplicated.

---

## 16. Security
- Treat all external input (users, files, web pages, third-party APIs, AI output) as untrusted: validate, size-limit, sanitize, schema-check.
- **Prompt-injection defense** (AI): untrusted text delimited as data; outputs whitelisted; no side effects without confirmation.
- **SSRF protection** for any server-side URL fetching: scheme allowlist, block private/loopback/metadata IPs after DNS resolution, cap redirects/size/time, isolated process.
- AuthN/AuthZ on every endpoint; least privilege; rate limits.
- Encrypt sensitive data at rest; HTTPS everywhere.
- Dependency + secret scanning in CI (`gitleaks`, ecosystem audit tools). Pin versions.
- Never log secrets, tokens, OTPs, full personal content, precise location.

---

## 17. Privacy & Data
- Collect the minimum; process locally where possible.
- Every stored data type has a documented retention rule.
- Users can export and delete their data.
- Clear, plain-language disclosure for every sensitive permission.

---

## 18. Observability
- Structured logs with `event`, `domain`, `provider`, `latency_ms`, `result`, `correlation_id`.
- A correlation id per user action propagated across client → server → providers.
- Metrics per provider (calls, errors, p50/p95, quota, breaker state).
- Health (`/health`) and readiness (`/ready`) endpoints for every service; crash reporting for every client.

---

## 19. API Design
- Versioned (`/v1`), contract-first (OpenAPI), generated clients.
- Envelope `{ data, meta, error: { code, message } }`, cursor pagination, ISO-8601 UTC, consistent casing.
- Long jobs: `202 Accepted` + job id, result via push/webhook/polling.

---

## 20. Data & Migrations
- Every schema change = a reviewed, tested migration. Forward-only in production.
- Repositories return domain models, never ORM entities.
- Offline-first clients: local store is UI source of truth; sync via an outbox with retries.
- Automated backups for any server database.

---

## 21. UI Standards (if applicable)
- Unidirectional data flow (events → state holder → immutable state → view).
- Design tokens only (no raw colors/sizes/strings in components); all strings externalized for i18n.
- Every screen handles loading / empty / error / success.
- Accessibility: labels, ≥ 44–48 px/dp targets, dynamic type, contrast, screen-reader tested.
- Dark mode from day one. Motion per DESIGN.md with a reduced-motion fallback.

---

## 22. Dependencies
- Central version management (version catalog / lockfiles), exact pins.
- New dependency needs a one-line justification (why, license, size, maintenance).
- Choose the newest **mutually compatible** set, documented in ADR 0003; automated update PRs, one bump per PR.

---

## 23. Feature Flags & Releases
- New user-facing work behind flags (default off).
- Semantic versioning; `CHANGELOG.md` (Keep a Changelog) per release.
- Reproducible release builds from CI; signing keys never in the repo.

---

## 24. Documentation
- `README.md` per deployable part: purpose, how to run, how to test.
- ADRs for every non-obvious decision. Diagrams as code (Mermaid).
- Generated docs (API, catalogs) come from code — never hand-maintained copies.

---

## 25. Developer Experience
- One command each: `make setup`, `make lint`, `make test`, `make check`, `make run-<part>`.
- Pre-commit hooks: format, lint, types, `scripts/check-rules.sh`, secret scan.
- Fakes for every gateway so each app can run fully offline in a demo mode.

---

## 26. Hard Don'ts
- ❌ Calling a provider or raw client from anywhere but its gateway.
- ❌ Provider-specific fields leaking into domain models.
- ❌ Business logic in UI, routes, controllers or DB layers.
- ❌ Executing generated/dynamic code from untrusted sources.
- ❌ Floats for money, naive datetimes, hard-coded secrets.
- ❌ Copy-pasting instead of extracting shared logic.
- ❌ Trusting AI output, web content or user input without validation.
- ❌ Global mutable state; blocking the main thread.
- ❌ Weakening a lint/type/test rule, adding a suppression, or skipping a test to make CI green.
{{PROJECT_SPECIFIC_DONTS — legal lines, ToS, platform policies}}

---

## 27. Definition of Done
- [ ] Layering + gateway rules respected (§2, §3); no duplication introduced
- [ ] Names follow §6; typed results/errors; no silent catches
- [ ] Input validated at boundaries; security & privacy rules respected
- [ ] Resilience for any new external call
- [ ] Logs/metrics with correlation id
- [ ] Tests per §11 passing; migrations tested if schema changed
- [ ] `make check` green; no new suppressions; performance budgets not regressed
- [ ] UI: tokens only, all states, accessible, previews/screenshots updated
- [ ] Behind a feature flag if user-facing
- [ ] Config + `.env.example` updated; no secrets committed
- [ ] PROGRESS / ADR / CHANGELOG / INCIDENTS updated as needed
