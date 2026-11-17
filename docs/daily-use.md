# Daily use

After setup, restart Claude Code in the project root. From then on, every working session has the same shape:

```text
/start-session [optional focus]
… describe the task, or approve the plan it proposes …
/end-session
```

The point is that **the project remembers, not the chat.** Status, lessons and decisions live in `docs/` as plain
Markdown, so a new chat, a restart or a different person picks up exactly where the last session stopped.

## Slash commands

Installed into `.claude/commands/`. Each one is a short Markdown prompt you can read and edit.

| Command | What it does | Waits for you |
|---|---|---|
| `/start-session [focus]` | Reads PROGRESS (snapshot, phase tracker, last session, known issues) and INCIDENTS (lessons, open incidents), checks `git status` and the last 10 commits, then replies with where things stand, relevant lessons and a plan of 3–6 small tasks. | before writing code — your own task prompt takes priority |
| `/end-session` | Summarizes what changed; updates PROGRESS (snapshot, tracker, inventory, decisions, a new session-log entry, known issues); writes ADRs for decisions; logs incidents; runs `make check` and says plainly if anything is still red; names the first task for next time. | — |
| `/plan-feature <description>` | Finds the feature in PLAN, reads related ADRs and lessons, lists what can be reused and what's missing, and gives a step-by-step plan in small commits with tests, a feature flag and a "done when" test, plus risks. | before coding |
| `/new-provider <domain> <name> [docs-url]` | Adds a provider to an existing gateway: provider file, mapper, recorded fixtures, contract tests, a config line. Verifies no caller changed. If the gateway doesn't exist yet, proposes it first. | if a new gateway is needed |
| `/new-screen <name> <purpose>` | Builds a screen or component from `docs/DESIGN.md`: one hero element and one primary action, tokens only, motion from the design system, all four states (loading/empty/error/success), previews and screenshot tests, then the design checklist. | — |
| `/log-incident <title>` | Adds the next `INC-XXXX` to INCIDENTS with every field (symptom, impact, root cause, fix, prevention…), adds a lesson, makes sure a regression test exists. Proposes a `CLAUDE.md` rule if the lesson should apply everywhere. | before changing `CLAUDE.md` |
| `/new-adr <title>` | Writes the next numbered decision record with context and evidence, alternatives, consequences and a "revisit when" trigger; marks any superseded ADR; links it from PROGRESS. | — |

## Reviewer agents

Installed into `.claude/agents/`. Three review and never edit; one writes tests.

| Agent | Checks the current diff against | Output |
|---|---|---|
| `architecture-reviewer` | layering, the gateway/provider rules, feature boundaries, generated contracts, naming, typed results, config and secrets, duplication, tests, Definition of Done | BLOCKER / MAJOR / MINOR with file:line and a fix, then *Approve* or *Changes required* |
| `security-reviewer` | input validation, prompt injection, SSRF, auth and rate limits, secrets in code/bundles/logs, permissions, data retention, logs | CRITICAL / HIGH / MEDIUM / LOW with file:line and a fix |
| `ui-reviewer` | `DESIGN.md`: tokens only, hierarchy, motion, feedback, all states, accessibility, previews | BLOCKER / MAJOR / MINOR, then the design checklist ✅/❌ |
| `test-writer` | missing tests for domain, use cases, providers, gateways, endpoints and UI | new deterministic tests (fakes, not mocks); reports bugs instead of silently fixing production code |

`/plan-feature` runs `architecture-reviewer` (and `ui-reviewer` for UI) before each commit. Ask for
`security-reviewer` on anything that touches external input, AI, networking, auth, storage or permissions.

## The lint hook

`.claude/settings.json` runs [`hooks/post-edit-lint.sh`](../templates/.claude/hooks/post-edit-lint.sh) after every
`Edit`, `Write` or `MultiEdit`. It formats and lints just the edited file:

| Files | Tools |
|---|---|
| `.py` | ruff format + ruff check (via `uv`) |
| `.kt` `.kts` | ktlint |
| `.ts` `.tsx` `.js` `.jsx` `.mjs` `.cjs` | prettier + eslint |
| `.swift` | swiftformat + swiftlint |
| `.go` · `.rs` · `.dart` | gofmt · rustfmt · dart format |

If a tool isn't installed, the hook skips it rather than failing. Real lint errors exit with code 2, which Claude Code
shows back to the agent so it fixes them before moving on. Setup adapts the commands to your stacks.

## The check gate

A second hook, [`hooks/stop-check.sh`](../templates/.claude/hooks/stop-check.sh), runs `make check` whenever Claude
tries to end a turn: format check, lint, strict types, import boundaries, [`scripts/check-rules.sh`](../templates/scripts/check-rules.sh)
and tests, for every part. If it fails, Claude is sent back with the last 60 lines of output instead of handing you red
code. It skips the run when nothing changed since the last green one, and after three blocked attempts in a row it lets
Claude stop and asks it to tell you plainly what's still failing — so a check it can't fix never loops forever.

`scripts/check-rules.sh` covers what no single linter does: every `TODO`/`FIXME` must link an issue (`TODO(#123): …`),
and the number of suppression comments (`noqa`, `type: ignore`, `@ts-expect-error`, `eslint-disable`, `@Suppress`…)
can't grow past `.suppressions-baseline`. Raising the baseline is your call: run `scripts/check-rules.sh --update` and
commit it with the reason.

Keep `make check` fast enough to run every turn. Put slow end-to-end and screenshot suites in their own target and in CI.

## Permissions

The same `settings.json` allows `make`, `git status`, `git diff` and `git log` without asking, and **denies** reading
`.env` files, `local.properties`, keystores, `.pem`/`.p12` keys and service-account JSON, plus `git push --force`.
It **asks you first** before Claude edits the things that keep the gate honest: lint and type configs (`ruff.toml`,
`mypy.ini`, `.importlinter`, `eslint.config.*`, `.dependency-cruiser.*`, `tsconfig*.json`, `detekt.yml`…), the
`Makefile`, `.pre-commit-config.yaml`, `.github/`, `scripts/check-rules.sh` and `.suppressions-baseline`. This is a
speed bump, not a wall — a shell command could still change them — so CODEOWNERS and branch protection on `main` are
the real backstop.
Your own `.claude/settings.local.json` is kept by setup and git-ignored.
