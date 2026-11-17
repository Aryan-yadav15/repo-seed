---
description: End a work session — update PROGRESS, log incidents, summarize
---
Close the current work session.

1. Summarize what changed (git diff / commits since session start).
2. Update `docs/PROGRESS.md`: Current Snapshot, Phase Tracker, Inventory tables, Decisions Log, a new Session Log entry at the top, Known Issues / Tech Debt.
3. Write an ADR in `docs/adr/` for any architectural decision made (use `/new-adr`).
4. If anything broke non-trivially or a fix took > 30 min, run the `/log-incident` flow.
5. Run `make check`; it must be green before you finish (the Stop hook enforces this). If something can't be fixed this session, say so plainly in your summary and record it in Known Issues.
6. Reply with a 5-line summary and the first task for next session.
