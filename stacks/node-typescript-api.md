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

## Commands
`pnpm lint` · `pnpm typecheck` · `pnpm test` · `pnpm dev` · `pnpm db:migrate`
