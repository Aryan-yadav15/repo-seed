# INCIDENTS.md — Bugs, Breakages & Lessons

> Every time something breaks in a non-trivial way (provider died, external UI/API changed, wrong output sent, crash, data loss, bad AI output, a fix that took > 30 min), log it here.
> Goal: **never solve the same problem twice.** Claude Code must read the "Lessons" section before touching an area listed there.

---

## Lessons (read first — distilled rules from past incidents)
| Area | Rule learned | From incident |
|---|---|---|
| | | |

---

## Open Incidents
| ID | Date | Title | Severity | Area | Owner |
|---|---|---|---|---|---|

Severity: **S1** user data loss / wrong critical output / security issue · **S2** feature broken · **S3** degraded / workaround exists · **S4** cosmetic

---

## Incident Log (newest first)

### INC-0001 — <short title>
- **Date / detected by:** YYYY-MM-DD · <me | test | monitoring | user>
- **Severity:** S1 / S2 / S3 / S4
- **Area:** <module | gateway:provider | feature | ui | infra | build/CI>
- **Symptom:** what was seen
- **Impact:** what/who was affected, for how long
- **Root cause:** the real why (5-whys if needed)
- **Fix:** what changed (commit / PR link)
- **Prevention:** test added, alert added, rule added to CLAUDE.md / Lessons
- **Status:** Open · Mitigated · Resolved
- **Time to resolve:**

---

## Recurring Watch-list
Fragile external dependencies to re-check when something feels off:
- {{unofficial APIs, free-tier quotas, scraped sites, platform policy changes, pre-release tools}}
