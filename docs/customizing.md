# Customizing the kit

The kit is meant to change as you do. Keep one master copy somewhere permanent, copy it into each new project as
`_kit/`, and fold lessons back into the master copy.

## Add a lesson that applies everywhere

When a project teaches you something that should hold for every future project, add it to
[`templates/CLAUDE.md`](../templates/CLAUDE.md) — usually under §26 *Hard don'ts* or §27 *Definition of done*, or in the
section it belongs to. Inside a project, `/log-incident` already proposes `CLAUDE.md` additions for that project; this
is the same move one level up.

## Add a stack

Create `stacks/<stack>.md` with the same sections as the existing files:

```markdown
# <part>/CLAUDE.md — <Stack> rules

Applies to everything under this folder. Root `CLAUDE.md` still applies.

## Stack           languages, frameworks, libraries, quality tools
## Layout          the folder tree, with domain / application / integrations / core
## Rules           how the layering and gateway rules look in this stack
## Testing         what gets tested and how
## Commands        lint · test · run · build
```

Phase B picks it whenever it fits a part of the new project. Without a matching file, setup writes an equivalent one
on the fly — if it turns out well, copy it back into `stacks/`.

## Change the design system

[`templates/docs/DESIGN.md`](../templates/docs/DESIGN.md) is a full default design system ("Still": calm, premium,
spring-based motion). Setup keeps its structure and motion system and adapts palette, typography and components to your
answer about the UI. Replace it with your own house style if you have one; keep the token names so the `ui-reviewer`
agent and `/new-screen` still apply.

## Adapt commands, agents and the hooks

- **Commands** in `templates/.claude/commands/` are short Markdown prompts with a `description` and optional
  `argument-hint` header. Add one by adding a file; its name becomes the command.
- **Agents** in `templates/.claude/agents/` have `name`, `description` and `tools` headers. Reviewers are read-only by
  design (`tools: Read, Grep, Glob, Bash`).
- **The hook** [`post-edit-lint.sh`](../templates/.claude/hooks/post-edit-lint.sh) maps file extensions to tools. Add a
  case for a new language; keep the rule that a missing tool is skipped and a real error exits 2.
  [`stop-check.sh`](../templates/.claude/hooks/stop-check.sh) only calls `make check`, so change what the gate runs in
  the project's `Makefile`, not in the hook.
- **Repo rules** in [`scripts/check-rules.sh`](../templates/scripts/check-rules.sh): add a pattern to `SUPPRESS` for a
  new language's suppression syntax, and a path to `EXCLUDE` for generated code.
- **A new stack file** needs an "Enforced rules" table: every rule a linter can decide, the exact rule that enforces it,
  and a failure message that names the fix. Rules that can't be linted reliably say so and name the reviewer agent instead.
- **Permissions** in [`settings.json`](../templates/.claude/settings.json): extend `allow` with commands you never want
  to be asked about, `ask` with the lint/type config files your stacks use, and `deny` with files that hold secrets.

## Change the setup itself

[`SETUP_PROMPT.txt`](../SETUP_PROMPT.txt) is plain text. Common edits: the 9 Phase A questions, what Phase E puts in the
skeleton, and whether Phase F deletes `_kit/` (line 63). Keep the two stops in Phases A and B — they're what keeps setup
from building the wrong thing.
