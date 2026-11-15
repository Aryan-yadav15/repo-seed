# Project Starter Kit for Claude Code

A reusable kit that turns an empty folder into a professionally structured project — rules, docs, memory, reviewers, quality gates, CI — in one Claude Code run.

## How to use (every new project)

1. Create an empty project folder, e.g. `~/Codes/MyNewApp`.
2. Copy this whole kit into it as a folder named `_kit/`:
   ```
   MyNewApp/
   └── _kit/        ← this kit
   ```
3. *(Optional but recommended)* Write your idea into `_kit/BRIEF.md` — paste anything: a chat summary, features, who it's for, platforms. If it's missing, Claude will interview you instead.
4. Open Claude Code **in `MyNewApp/`** and paste the contents of `SETUP_PROMPT.txt`.
5. Answer its questions, approve the plan, let it build the skeleton.
6. When it finishes: restart Claude Code in the project root, then always work like this:
   - `/start-session` → paste/describe the task → work → `/end-session`

## What's inside

```
_kit/
├── README.md              ← you are here
├── SETUP_PROMPT.txt       ← paste this into Claude Code once per new project
├── BRIEF.md               ← (you create, optional) your project idea
├── templates/
│   ├── CLAUDE.md          ← universal engineering rules (stack-agnostic)
│   ├── docs/
│   │   ├── PLAN.md        ← what we build (filled from your brief)
│   │   ├── DESIGN.md      ← how it looks & moves (UI projects only)
│   │   ├── PROGRESS.md    ← where we are (session memory)
│   │   ├── INCIDENTS.md   ← what broke + lessons
│   │   └── adr/0000-template.md  ← decision record template
│   └── .claude/
│       ├── settings.json  ← permissions + auto-lint hook
│       ├── commands/      ← /start-session /end-session /plan-feature /new-provider /new-screen /log-incident /new-adr
│       ├── agents/        ← architecture / ui / test / security reviewers
│       └── hooks/post-edit-lint.sh
└── stacks/                ← per-stack rule add-ons, copied into sub-folder CLAUDE.md files
    ├── android-kotlin.md
    ├── python-fastapi.md
    ├── web-nextjs.md
    └── node-typescript-api.md
```

## The architecture this kit enforces (in one screen)

- **Layers with one-way dependencies:** UI → application/use cases → domain ← data/integrations ← core. Domain is pure.
- **Provider → Gateway pattern:** every external service (APIs, AI models, payments, maps…) sits behind ONE gateway per domain that handles provider choice, fallback, caching, rate limits, retries, circuit breaking and mapping to your own models. Callers never touch providers.
- **Typed results and errors**, validation at boundaries, config-driven behavior, secrets only in env.
- **Memory files** (PROGRESS, INCIDENTS, ADRs) so Claude never loses context between sessions.
- **Robots:** lint, type checks, import-boundary checks, tests, screenshot tests (UI), CI on every push, auto-lint hook on every edit, reviewer agents before commits.

## Tips
- Keep `_kit/` somewhere permanent (e.g. `~/Codes/_kit`) and copy it per project.
- Improve the kit over time: when a project teaches you a lesson that applies everywhere, add it to `templates/CLAUDE.md`.
- Add a new stack by creating `stacks/<stack>.md` following the same sections as the others.
