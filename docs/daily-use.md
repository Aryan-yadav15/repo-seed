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
| `/end-session` | Summarizes what changed; updates PROGRESS (snapshot, tracker, inventory, decisions, a new session-log entry, known issues); writes ADRs for decisions; logs incidents; confirms lint and tests pass; names the first task for next time. | — |
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

## Permissions

The same `settings.json` allows `make`, `git status`, `git diff` and `git log` without asking, and **denies** reading
`.env` files, `local.properties`, keystores, `.pem`/`.p12` keys and service-account JSON, plus `git push --force`.
Your own `.claude/settings.local.json` is kept by setup and git-ignored.
