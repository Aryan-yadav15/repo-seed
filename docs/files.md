# Files in the kit

| File | What it is | Ends up as |
|---|---|---|
| [`SETUP_PROMPT.txt`](../SETUP_PROMPT.txt) | The setup instructions you paste into Claude Code: phases A–F | — (used once) |
| `BRIEF.md` | Optional, **you** create it in `_kit/`: your idea in any form | read in phase A |
| [`templates/CLAUDE.md`](../templates/CLAUDE.md) | The stack-agnostic rulebook, 28 sections | `CLAUDE.md` |
| [`stacks/*.md`](../stacks/) | Per-stack rules: Android/Kotlin, Python/FastAPI, Web/Next.js, Node/TypeScript API | `<part>/CLAUDE.md` |
| [`templates/docs/PLAN.md`](../templates/docs/PLAN.md) | Product plan: problem, users, architecture, gateways, data, features, stack, roadmap, costs, risks, legal | `docs/PLAN.md` |
| [`templates/docs/DESIGN.md`](../templates/docs/DESIGN.md) | Default design system: theme, color, type, components, layout, depth, motion, prompt guide | `docs/DESIGN.md` (UI only) |
| [`templates/docs/PROGRESS.md`](../templates/docs/PROGRESS.md) | Build log: snapshot, phase tracker, inventory, decisions, session log, tech debt | `docs/PROGRESS.md` |
| [`templates/docs/INCIDENTS.md`](../templates/docs/INCIDENTS.md) | Lessons, open incidents, incident log with severities | `docs/INCIDENTS.md` |
| [`templates/docs/adr/0000-template.md`](../templates/docs/adr/0000-template.md) | Decision record: context, decision, alternatives, consequences, revisit-when | `docs/adr/` |
| [`templates/.claude/settings.json`](../templates/.claude/settings.json) | Permissions (secrets unreadable, gate configs need your OK) and both hooks | `.claude/settings.json` |
| [`templates/.claude/commands/`](../templates/.claude/commands/) | 7 slash commands | `.claude/commands/` |
| [`templates/.claude/agents/`](../templates/.claude/agents/) | 4 agents: architecture, security, UI reviewers; test writer | `.claude/agents/` |
| [`templates/.claude/hooks/post-edit-lint.sh`](../templates/.claude/hooks/post-edit-lint.sh) | Format + lint each edited file | `.claude/hooks/` (made executable) |
| [`templates/.claude/hooks/stop-check.sh`](../templates/.claude/hooks/stop-check.sh) | Runs `make check` before Claude ends a turn; sends it back on failure | `.claude/hooks/` (made executable) |
| [`templates/scripts/check-rules.sh`](../templates/scripts/check-rules.sh) | TODOs must link an issue; suppression comments can't grow past the baseline | `scripts/` (made executable) |
| `docs/` (this folder) | Documentation of the kit itself | — (deleted with `_kit/`) |
