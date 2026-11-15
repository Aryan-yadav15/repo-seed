---
description: End a work session — update PROGRESS, log incidents, summarize
---
Close the current work session.

1. Summarize what changed (git diff / commits since session start).
2. Update `docs/PROGRESS.md`: Current Snapshot, Phase Tracker, Inventory tables, Decisions Log, a new Session Log entry at the top, Known Issues / Tech Debt.
3. Write an ADR in `docs/adr/` for any architectural decision made (use `/new-adr`).
4. If anything broke non-trivially or a fix took > 30 min, run the `/log-incident` flow.
5. Confirm lint + tests pass; if not, record it in Known Issues.
6. Reply with a 5-line summary and the first task for next session.
