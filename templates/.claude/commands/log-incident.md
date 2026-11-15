---
description: Log a bug/breakage in INCIDENTS.md and capture the lesson
argument-hint: <short title>
---
Log incident: $ARGUMENTS

1. Open `docs/INCIDENTS.md`; assign the next `INC-XXXX` id.
2. Fill every field: date, detected by, severity (S1–S4), area, symptom, impact, root cause (5 whys), fix (commit), prevention, status, time to resolve. Include exact error messages.
3. Update "Open Incidents" (remove when Resolved).
4. Add a generalizable rule to "Lessons" with the incident id.
5. If the rule should constrain all future code, propose a CLAUDE.md addition (wait for OK).
6. Ensure a regression test exists.
