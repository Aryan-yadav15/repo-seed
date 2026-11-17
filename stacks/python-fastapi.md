# <part>/CLAUDE.md — Python (FastAPI) rules

Applies to everything under this folder. Root `CLAUDE.md` still applies.

## Stack
- Python 3.12+, FastAPI, Pydantic v2 + pydantic-settings, SQLAlchemy 2 (async) + Alembic, httpx (async).
- Env/deps: `uv` with lockfile, exact pins, dev deps in a dependency group.
- Quality: `ruff` (lint + format), `mypy --strict`, `import-linter`, `pytest` + `pytest-asyncio` + `respx`.

## Layout
```
app/
  main.py            app factory, routers, middleware (correlation id, error envelope)
  api/v1/            routers only — parse, call service, return envelope
  core/              config.py · container.py (DI wiring) · errors.py · result.py · logging.py
                     cache.py · rate_limit.py · circuit_breaker.py
  domain/models/     frozen pydantic domain models
  domain/services/   business logic; gateways injected via constructor
  integrations/<domain>/  base.py (Protocol) · gateway.py (only public entry) · providers/ · mappers.py
  db/                models · session · repositories
  jobs/              background/scheduled jobs (idempotent)
tests/               mirrors app/; fakes/ · contracts/ · fixtures/<provider>/
config/              providers.yaml · flags.yaml
migrations/          alembic
```

## Rules
- Async all the way for I/O; CPU-heavy work in a process pool.
- Wiring only in `core/container.py`; routes get services via `Depends`.
- import-linter contracts: `api → domain.services → integrations.*.gateway`; nobody imports `integrations.*.providers` except its gateway/container.
- Settings via pydantic-settings; app **startup** fails on missing required env (test it). Keep `app.main:app` import side-effect free (lazy factory).
- Envelope `{data, meta, error}`; one exception handler maps typed errors to status codes.
- Long jobs: `202` + job id.
- Structured JSON logs with correlation id.

## Enforced rules
Config in `ruff.toml`, `mypy.ini` and `.importlinter` (not `pyproject.toml`) so `.claude/settings.json` can protect them.

| Rule | Enforced by |
|---|---|
| Layering and private providers | import-linter contracts, each **named as the fix** (`"routes call domain.services, never db or integrations"`) |
| No `print` | ruff `T20` |
| No commented-out code | ruff `ERA` |
| No `Any` in signatures | ruff `ANN401` + `mypy --strict` |
| No blanket `noqa` / `type: ignore`; no stale ones | ruff `PGH003`, `PGH004`, `RUF100`; mypy `enable_error_code = ignore-without-code` (strict already warns on unused ignores) |
| No sleeps or raw HTTP clients outside `core/` and providers | ruff `TID251` banned-api with a `msg` naming the replacement (`core.clock`, the gateway), allowed via `per-file-ignores` only there |
| TODO links an issue; suppressions don't grow | `scripts/check-rules.sh` |

## Testing
- Contract suite per domain parametrized over providers; gateway behavior tests; startup fail-fast tests; mutation-check critical tests occasionally (break the code, confirm a test fails).

## Commands
`make check` (everything below plus repo rules) · `uv run ruff check . && uv run ruff format --check . && uv run mypy app && uv run lint-imports` · `uv run pytest` · `uv run uvicorn app.main:app --reload` · `uv run alembic upgrade head`
