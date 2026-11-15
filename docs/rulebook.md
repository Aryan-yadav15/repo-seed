# The rulebook

[`templates/CLAUDE.md`](../templates/CLAUDE.md) becomes your project's root `CLAUDE.md`: the rules every change must
follow. It's stack-agnostic; each deployable part also gets a stack file from [`stacks/`](../stacks/), and both apply.
It opens with "Uniformity beats cleverness" — every module, provider and feature follows one repeatable recipe so
humans and AI agents can extend it safely.

## The core ideas

**Layers with one-way dependencies** (§2).

```
presentation (UI / API routes) → application (use cases) → domain ← data/integrations ← core
```

Domain logic is pure and imports no framework, UI, data or network code. Presentation is thin. Use cases talk to
gateways and repositories, never to providers or raw clients. An import-boundary linter in CI enforces it.

**Every outside service behind a gateway** (§3). Third-party APIs, AI models, payments, maps, storage, email —
anything external or swappable — gets one gateway per domain that owns provider choice, fallback, caching, rate
limits, retries, timeouts, circuit breaking and mapping to your own models. Providers are private. Adding a provider is
one provider file, one mapper, one config line and tests, with no caller changes; the gateway is built even when there's
only one provider.

**Typed results and errors** (§7). Business and integration code returns `Ok(value, meta)` or `Err(error)`, with a
fixed set of error types; exceptions are caught at the edge and never swallowed.

**Validate at boundaries, trust inside** (§0.1, §16). User input, files, web pages, provider responses and AI output
are all untrusted.

**Memory files** (header). `PLAN`, `DESIGN`, `PROGRESS`, `INCIDENTS` and `docs/adr/`, with a start/end session ritual.

## All 28 sections

| § | Section | § | Section |
|---|---|---|---|
| 0 | Why this codebase is strict — principles, patterns | 14 | Recipes for common changes |
| 1 | Repo layout | 15 | Resilience |
| 2 | Layering & dependency rule | 16 | Security |
| 3 | Provider → Gateway pattern | 17 | Privacy & data |
| 4 | Feature modules | 18 | Observability |
| 5 | Contracts & schemas | 19 | API design |
| 6 | Naming conventions | 20 | Data & migrations |
| 7 | Errors & results | 21 | UI standards |
| 8 | Configuration & secrets | 22 | Dependencies |
| 9 | Concurrency & performance | 23 | Feature flags & releases |
| 10 | AI / LLM usage | 24 | Documentation |
| 11 | Testing | 25 | Developer experience |
| 12 | Code quality gates | 26 | Hard don'ts |
| 13 | Git & workflow | 27 | Definition of done |

Setup replaces every `{{PLACEHOLDER}}`, fills in the repo layout (§1) and the project's gateway table (§3.3), and removes
sections that truly don't apply — it says which in its report.

## Stack rule files

| File | Stack | Key choices |
|---|---|---|
| [`android-kotlin.md`](../stacks/android-kotlin.md) | Android | Kotlin, Jetpack Compose, Coroutines + Flow, Hilt, Room, WorkManager; ktlint + detekt; Roborazzi screenshot tests; module map from `:app` to `:ui:screen:<feature>`; version lessons (Hilt sets the Kotlin ceiling, AGP 9 built-in Kotlin…) |
| [`python-fastapi.md`](../stacks/python-fastapi.md) | Python API | Python 3.12+, FastAPI, Pydantic v2, SQLAlchemy 2 async + Alembic, httpx; `uv`; ruff, `mypy --strict`, import-linter, pytest |
| [`web-nextjs.md`](../stacks/web-nextjs.md) | Web | Next.js App Router, React, strict TypeScript, Tailwind with token CSS variables, Motion; TanStack Query, Zod; Vitest, Playwright, Storybook; pnpm |
| [`node-typescript-api.md`](../stacks/node-typescript-api.md) | Node API | Node LTS, strict TypeScript, Fastify (or Hono), Zod, Drizzle or Prisma, pino; dependency-cruiser for layers; Vitest |

Each has the same shape: stack, layout, rules, testing, commands. For a stack that isn't here, setup writes an
equivalent file with the same sections. To add your own permanently, see [customizing](customizing.md).
