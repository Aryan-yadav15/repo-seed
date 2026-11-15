<!-- Cards are generated from docs/assets/cards.json with repo-polish (tools/cards/cards.py). -->

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/hero-dark.svg"/>
  <img src="docs/assets/hero-light.svg" width="100%" alt="repo-seed. Empty folder in. Real project out. A Claude Code kit that interviews you, plans the project, writes its rules and memory, and builds a working skeleton with CI."/>
</picture>

<p align="center">
  <a href="#-use-it"><b>Use it</b></a> &nbsp;·&nbsp;
  <a href="#-how-setup-works"><b>How setup works</b></a> &nbsp;·&nbsp;
  <a href="#-what-every-project-gets"><b>What you get</b></a> &nbsp;·&nbsp;
  <a href="docs/"><b>Docs</b></a>
</p>

**repo-seed turns an empty folder into a properly structured project in one Claude Code run** — before any feature
code exists. It asks what you're building, proposes a stack and a roadmap, and once you approve, writes the rules the
agent must follow, the plan, the memory files that carry context between sessions, slash commands, reviewer agents, a
lint hook, and an empty-but-working skeleton with CI. Then it commits and hands over.

Everything is plain Markdown and one prompt. No install, no service.

## ▸ Use it

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/terminal-dark.svg"/>
  <img src="docs/assets/terminal-light.svg" width="100%" alt="Terminal: make a folder, clone repo-seed into it as _kit, start Claude Code and paste the setup prompt; afterwards every session uses /start-session and /end-session."/>
</picture>

**1. Put the kit in an empty project folder as `_kit/`**

```bash
mkdir MyNewApp && cd MyNewApp
git clone https://github.com/Aryan-yadav15/repo-seed _kit
```

**2. Optional: write your idea into `_kit/BRIEF.md`** — a chat summary, a feature list, who it's for, platforms. Without
it, Claude interviews you instead (9 short questions).

**3. Start Claude Code in the project folder and paste [`_kit/SETUP_PROMPT.txt`](SETUP_PROMPT.txt)**

```bash
claude
```

**4. Answer its questions and approve the plan.** It stops twice: after the questions, and after proposing the stack,
layout, external-service gateways and roadmap. Then it writes, builds and verifies on its own.

**5. When it's done, restart Claude Code in the project root and work in sessions**

```text
/start-session
/end-session
```

## ▸ How setup works

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/architecture-dark.svg"/>
  <img src="docs/assets/architecture-light.svg" width="100%" alt="How setup works: you give a brief or answer 9 questions and approve the plan; SETUP_PROMPT.txt drives Claude Code through phases A to F; the result is rules and memory, a .claude folder with commands, agents and a hook, and a skeleton with CI."/>
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/flow-dark.svg"/>
  <img src="docs/assets/flow-light.svg" width="100%" alt="Six steps: copy the kit, brief, approve, write, build, verify."/>
</picture>

The full walkthrough — every phase, what it writes, and an interactive diagram linked to the prompt lines — is in
[docs/how-it-works.md](docs/how-it-works.md).

## ▸ What every project gets

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/capabilities-dark.svg"/>
  <img src="docs/assets/capabilities-light.svg" width="100%" alt="Session memory via /start-session; one gateway per outside service via /new-provider; reviewer agents before commits; quality gates from day one via the post-edit lint hook and CI."/>
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/decisions-dark.svg"/>
  <img src="docs/assets/decisions-light.svg" width="100%" alt="Five decisions: plan before code; memory lives in the repo; every outside service behind a gateway; versions researched, not guessed; the kit deletes itself."/>
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/editor-dark.svg"/>
  <img src="docs/assets/editor-light.svg" width="100%" alt="Lines 89 to 101 of templates/CLAUDE.md: the gateway reference shape — cache, then providers in configured order with rate limits and circuit breakers, then stale cache, then a typed error."/>
</picture>

<picture>
  <source media="(prefers-color-scheme: dark)" srcset="docs/assets/stack-dark.svg"/>
  <img src="docs/assets/stack-light.svg" width="100%" alt="Stack rule-sets included: Android (Kotlin, Jetpack Compose, Hilt, Room), Python API (FastAPI, Pydantic, SQLAlchemy, uv), Web (Next.js, React, Tailwind), Node API (TypeScript, Fastify, Zod, Drizzle or Prisma)."/>
</picture>

Other stacks work too: setup writes an equivalent rules file with the same sections, and you can keep it.
See [customizing](docs/customizing.md).

## ▸ What's in the kit

```
SETUP_PROMPT.txt         paste once per new project: phases A → F
templates/
  CLAUDE.md              the rulebook — 28 sections, stack-agnostic
  docs/                  PLAN · DESIGN · PROGRESS · INCIDENTS · adr/0000-template
  .claude/
    settings.json        permissions (secrets unreadable) + the lint hook
    commands/            /start-session /end-session /plan-feature /new-provider /new-screen /log-incident /new-adr
    agents/              architecture · security · ui reviewers, test-writer
    hooks/               post-edit-lint.sh
stacks/                  android-kotlin · python-fastapi · web-nextjs · node-typescript-api
docs/                    documentation of the kit (this README's long form)
```

## ▸ Good to know

- **Built for Claude Code.** The commands, agents, hook and `@docs/…` imports use Claude Code's conventions. Other
  agents can follow `CLAUDE.md` and the docs as plain instructions, without the commands and hook.
- **Setup is thorough, not instant.** It researches real package registries for compatible versions and loops until
  lint and tests pass.
- **`_kit/` deletes itself** at the end of setup, so keep your master copy somewhere permanent and improve it over time:
  when a project teaches you something that applies everywhere, add it to `templates/CLAUDE.md`.
- **It's opinionated.** Strict layering, a gateway for every external service, typed results, tests per layer. If that's
  more structure than a weekend script needs, trim the rulebook — or use it for the projects you want to last.
- **Keeping existing projects in shape:** see the companion kit [repo-polish](https://github.com/Aryan-yadav15/repo-polish).

| Read next | |
|---|---|
| [How it works](docs/how-it-works.md) | every phase, what it writes, the final report |
| [Daily use](docs/daily-use.md) | sessions, all 7 commands, the 4 agents, the hook, permissions |
| [The rulebook](docs/rulebook.md) | what the generated `CLAUDE.md` asks of every project |
| [Customizing](docs/customizing.md) | add a stack, change rules, commands, agents, design system |

## License

MIT. Fonts in the README cards: Bricolage Grotesque and Inter (SIL OFL). Logos: [Simple Icons](https://simpleicons.org)
(CC0); trademarks belong to their owners.
