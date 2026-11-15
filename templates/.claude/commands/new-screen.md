---
description: Build a UI screen/component per DESIGN.md
argument-hint: <screen name> <purpose>
---
New screen/component: $ARGUMENTS

Read `docs/DESIGN.md` fully first.
1. State the one hero element and the one primary action before coding.
2. Follow the stack's UI structure (screen + state holder + state + events) from the sub-folder CLAUDE.md.
3. Tokens only — no raw colors, sizes, durations, strings.
4. Motion from the design system's spring/transition tokens; interruptible; reduced-motion fallback. Haptics/feedback per DESIGN.md.
5. Loading / empty / error / success states.
6. Previews/stories in light, dark, large text; screenshot tests updated.
7. Run the DESIGN.md review checklist and report each item. Run ui-reviewer before committing.
