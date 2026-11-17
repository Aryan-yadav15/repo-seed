# <part>/CLAUDE.md — Node.js API (TypeScript) rules

Applies to everything under this folder. Root `CLAUDE.md` still applies.

## Stack
- Node LTS, TypeScript `strict`, Fastify (or Hono), Zod for validation, Drizzle or Prisma (decide in ADR) with migrations, pino structured logging.
- Quality: ESLint (typescript-eslint strict) + dependency-cruiser for layer rules, Prettier, Vitest, Supertest/light-my-request.
- pnpm with lockfile, exact versions.

## Layout
```
src/
  main.ts                 bootstrap (env fail-fast, DI container, server start)
  api/v1/                 route handlers (thin) + zod request/response schemas
  domain/                 models, pure logic
  application/            services / use cases
  integrations/<domain>/  provider.ts · gateway.ts (public) · providers/ · mappers.ts
  db/                     schema · migrations · repositories
  jobs/                   queues / schedulers (idempotent)
  core/                   result.ts · errors.ts · logger.ts · env.ts · clock.ts · container.ts · cache.ts · rateLimit.ts · circuitBreaker.ts
tests/                    mirrors src/; fakes/ · contracts/ · fixtures/
```

## Rules
- dependency-cruiser enforces `api → application → domain`, `application → integrations/*/gateway`, providers private.
- OpenAPI generated from zod schemas; clients generated from it.
- Envelope `{data, meta, error}`; one error handler; correlation id plugin.
- Graceful shutdown; health/readiness endpoints.

## Enforced rules
Config in `eslint.config.*`, `.dependency-cruiser.*` and `tsconfig*.json` so `.claude/settings.json` can protect them.

| Rule | Enforced by |
|---|---|
| Layering and private providers | dependency-cruiser rules, each with a `comment` naming the allowed path (`"use integrations/<domain>/gateway"`) |
| No `any` | `@typescript-eslint/no-explicit-any`, `no-unsafe-*` (strict-type-checked) |
| No `@ts-ignore`; `@ts-expect-error` only with a reason | `@typescript-eslint/ban-ts-comment` (`allow-with-description`) |
| No `console` | `no-console` (use the logger) |
| Disable comments need a reason; no stale ones | `@eslint-community/eslint-comments/require-description`; `linterOptions.reportUnusedDisableDirectives: "error"` |
| No `setTimeout`/`setInterval` in `domain/` and `application/` | `no-restricted-globals` with a message pointing to `core/clock.ts` |
| TODO links an issue; suppressions don't grow | `scripts/check-rules.sh` |

## Commands
`make check` (everything below plus repo rules) · `pnpm lint` · `pnpm typecheck` · `pnpm test` · `pnpm dev` · `pnpm db:migrate`
