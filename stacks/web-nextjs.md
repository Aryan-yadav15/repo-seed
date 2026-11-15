# <part>/CLAUDE.md — Web (Next.js + TypeScript) rules

Applies to everything under this folder. Root `CLAUDE.md` still applies. UI work must follow `docs/DESIGN.md`.

## Stack
- Next.js (App Router), React, TypeScript `strict`, Tailwind CSS with design tokens as CSS variables, Motion (Framer Motion) for animation.
- Data: TanStack Query for client fetching; server actions/route handlers thin.
- Validation: Zod at every boundary (forms, API input, env, external responses).
- Quality: ESLint (typescript-eslint strict + `eslint-plugin-boundaries` or `dependency-cruiser` for layers), Prettier, Vitest + Testing Library, Playwright (e2e + visual snapshots), Storybook for components.
- Package manager: pnpm with lockfile, exact versions.

## Layout
```
src/
  app/                    routes (thin): page.tsx, layout.tsx, route handlers
  features/<feature>/     components/ · hooks/ · state/ · feature-level use cases
  domain/                 models (types + zod schemas), pure logic
  application/            use cases / services
  integrations/<domain>/  provider.ts (interface) · gateway.ts (public) · providers/ · mappers.ts   (server-only)
  ui/                     design system: tokens.css · primitives · motion presets
  lib/                    result.ts · errors.ts · logger.ts · env.ts (zod, fail-fast) · clock.ts
tests/ e2e/ .storybook/
```

## Rules
- Server-only code (`integrations/`, secrets) marked with `import "server-only"`; never imported by client components.
- Env parsed once in `lib/env.ts` with Zod; build/start fails if missing.
- Components: no fetching inside presentational components; props typed; no `any`.
- Tokens only (CSS variables); no hard-coded colors/spacing in components.
- Motion presets in `ui/motion.ts` mirror DESIGN.md springs; respect `prefers-reduced-motion`.
- Images via `next/image`; fonts via `next/font` (self-hosted, licensed).
- Accessibility: semantic HTML, keyboard navigation, focus rings, axe checks in tests.
- Performance budgets: LCP < 2.5 s, CLS < 0.1, route JS budget tracked in CI.

## Commands
`pnpm lint` · `pnpm typecheck` · `pnpm test` · `pnpm e2e` · `pnpm build` · `pnpm storybook`
