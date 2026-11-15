# DESIGN.md — {{PROJECT_NAME}} Design System

> **TEMPLATE NOTE (remove after filling):** This is a default premium design system ("Still"). Keep the structure, depth system and the full Motion section. Adapt palette, type, components and the "Overlays/Signature surfaces" section (§7) to this project. Replace Compose-specific notes in §12 with the chosen UI stack (SwiftUI / React + Tailwind + Framer Motion / Flutter…), keeping the same token names. Never copy another brand's logo, fonts or icons.


> Calm, premium, physical. Every pixel feels considered; every motion feels like it has mass.
> Follows the DESIGN.md format (Visual Theme → Color → Type → Components → Layout → Depth → Do/Don't → Responsive → Agent Prompt Guide), extended with **Motion** and **Signature Surfaces** (§7 — the example below shows overlays from a past project; replace with this project's hero surfaces).
>
> Implementation: Jetpack Compose. Tokens live in `android/ui/designsystem/`. **No hardcoded values anywhere else** (see CLAUDE.md §21).

---

## 1. Visual Theme & Atmosphere

**Name:** *Still* — the app should feel like a quiet, well-made object, not a dashboard.

- **Mood:** calm, confident, unhurried. Premium consumer hardware, not "productivity tool".
- **Density:** low. Generous whitespace. One idea per surface. When in doubt, remove.
- **Materials:** soft neutral canvas, frosted translucent layers, a single vivid accent used sparingly.
- **Shape language:** continuous-curvature rounded rectangles (squircle feel), pill buttons, no sharp corners anywhere.
- **Motion:** physics-based springs, never linear. Things *settle*, they don't *stop*. Elements morph from where you touched them.
- **Haptics:** every meaningful state change has a matching, subtle haptic.
- **Voice:** short, human, lowercase-friendly microcopy. "Saved." not "Your item has been saved successfully!"

**Three words to test every screen against:** *quiet · tactile · obvious.*

---

## 2. Color Palette & Roles

Semantic tokens only. Components reference roles (`Surface.primary`), never hex.

### 2.1 Light
| Token | Hex | Role |
|---|---|---|
| `bg.canvas` | `#F4F4F6` | App background |
| `bg.elevated` | `#FFFFFF` | Cards, sheets |
| `bg.grouped` | `#ECECF0` | Grouped list background, input fields |
| `material.thin` | `#FFFFFF` @ 72% + blur 30 | Overlays, bubbles, nav bars |
| `material.thick` | `#FFFFFF` @ 88% + blur 40 | Sheets over content |
| `text.primary` | `#111114` | Titles, body |
| `text.secondary` | `#5E5E66` | Subtitles, meta |
| `text.tertiary` | `#9A9AA3` | Placeholders, disabled |
| `separator` | `#111114` @ 8% | Hairlines (0.5dp) |
| `accent` | `#3D6BFF` | Primary actions, active states, links |
| `accent.soft` | `#3D6BFF` @ 12% | Selected chips, accent backgrounds |
| `success` | `#22B573` | Confirmed, available, saved |
| `warning` | `#F2A93B` | Low seats, nearing limit |
| `danger` | `#F04A4A` | Waitlist, limit reached, destructive |
| `info` | `#8B6CFF` | AI-generated content marker |

### 2.2 Dark (true-black OLED friendly)
| Token | Hex | Role |
|---|---|---|
| `bg.canvas` | `#000000` | App background |
| `bg.elevated` | `#141416` | Cards |
| `bg.grouped` | `#1C1C1F` | Inputs, grouped lists |
| `material.thin` | `#1C1C1F` @ 70% + blur 30 | Overlays |
| `material.thick` | `#1C1C1F` @ 86% + blur 40 | Sheets |
| `text.primary` | `#F5F5F7` | |
| `text.secondary` | `#A1A1AA` | |
| `text.tertiary` | `#63636B` | |
| `separator` | `#FFFFFF` @ 10% | |
| `accent` | `#5B82FF` | Slightly lifted for contrast |
| `success` | `#30C985` | |
| `warning` | `#FFB84D` | |
| `danger` | `#FF5C5C` | |
| `info` | `#9E85FF` | |

### 2.3 Feature tints (tile identity, used at 12–16% as backgrounds, 100% for icon glyph)
`tint.focus #3D6BFF` · `tint.money #22B573` · `tint.travel #FF8A3D` · `tint.places #F0507A` · `tint.content #8B6CFF` · `tint.files #2BB3C0` · `tint.health #FFB020`

### 2.4 Rules
- **One accent per screen.** Feature tints only on icons/tiles, never on buttons.
- Status colors only carry meaning (available / low / waitlist) — never decoration.
- Contrast: text ≥ 4.5:1, large text/icons ≥ 3:1, in both themes.
- No pure-black text on light; no pure-white surfaces in dark.

---

## 3. Typography Rules

**Family:** **Inter** (variable, OFL-licensed) with `ss01`, `cv11` features and tight optical tracking. Numbers use **tabular figures** (`tnum`) everywhere data changes (counters, prices, seats, timers).
Fallback: system sans. Monospace (rare, PNRs/codes): **JetBrains Mono**.

| Token | Size / Line | Weight | Tracking | Use |
|---|---|---|---|---|
| `display` | 40 / 44 | 700 | -0.8 | Hero numbers (reels today, price) |
| `title.l` | 30 / 36 | 700 | -0.5 | Screen titles (large) |
| `title.m` | 22 / 28 | 600 | -0.3 | Section titles, sheet titles |
| `title.s` | 18 / 24 | 600 | -0.2 | Card titles |
| `body` | 16 / 22 | 400 | -0.1 | Default text |
| `body.emph` | 16 / 22 | 600 | -0.1 | Inline emphasis |
| `callout` | 15 / 20 | 500 | 0 | Buttons, list rows |
| `footnote` | 13 / 18 | 400 | 0 | Meta, timestamps |
| `caption` | 12 / 16 | 500 | 0.2 | Chips, labels |
| `micro` | 11 / 13 | 600 | 0.4 | Overlay badges (uppercase allowed only here) |

### Rules
- Max **3 sizes per screen.** Hierarchy comes from weight + color before size.
- Large title collapses into a compact 17/22 600 title in the top bar on scroll (animated, see §10).
- Respect system font scale up to 200%; layouts must reflow, not truncate critical info.
- Numbers that change **animate digit-by-digit** (rolling counter, §10.5).

---

## 4. Component Stylings

All components: min touch target **48dp**, corner radii from §5.3, press feedback = scale 0.97 + haptic (§10.6).

### 4.1 Buttons
| Variant | Style | Use |
|---|---|---|
| `Primary` | Pill, `accent` fill, white `callout` 600, height 52 | One per screen max |
| `Secondary` | Pill, `accent.soft` fill, `accent` text | Alternatives |
| `Tertiary` | Text only, `accent` | Inline, low emphasis |
| `Destructive` | Pill, `danger` @ 12% fill, `danger` text | Delete, block |
| `Icon` | 44dp circle, `material.thin` | Toolbars, overlays |

States: pressed (scale 0.97, 85% opacity), disabled (`text.tertiary`, no fill change animation), loading (label crossfades to a 3-dot pulse; width stays fixed).

### 4.2 Feature Tile (home grid)
- Size: 1×1 (square) or 2×1 (wide). Radius `r.xl` (28).
- Background `bg.elevated`; icon glyph 28dp on a 48dp `tint` @ 14% squircle top-left.
- Title `title.s`, live value `display` or `title.m` (e.g. "47 reels").
- Long-press → lifts (scale 1.03, shadow `e3`), haptic, context menu with blur behind (§10).
- Tap → **container transform** into the feature screen (shared element: icon + title + value).

### 4.3 Cards
- Radius `r.l` (22), padding 20, `bg.elevated`, elevation `e1` (light) / hairline border (dark).
- Header row: tint icon · `title.s` · trailing meta `footnote`.
- Swipe actions (archive, delete, pin) revealed with rubber-band resistance.

**Specialized cards**
- **Trip Option Card:** route line (dots + connecting line), times `title.s` tabular, status pill (AVL green / RAC amber / WL red) with live count that rolls on change.
- **Place Card:** 16:10 thumbnail from reel frame, name, area, cuisine chips, "Open in Maps" secondary button.
- **Site Card:** favicon, title, 2-line summary, 3 fact chips (Free · No login · Safe), outcome buttons (Save / Pin / Build).
- **Screenshot Card:** image with 18 radius, tag chip overlaid bottom-left on `material.thin`.

### 4.4 Chips & Pills
Height 32, radius full, `caption` 500. Unselected `bg.grouped`; selected `accent.soft` + `accent` text with a 200 ms spring color morph. Status pills use status colors @ 14% bg + full-color text.

### 4.5 Inputs
- **Prompt bar** (the heart of the app): pill, height 56, `material.thin`, leading sparkle glyph, placeholder "What do you want this app to do?" Expands into a sheet on focus (§10.4).
- Text fields: `bg.grouped`, radius `r.m`, no borders; focus = 1.5dp `accent` ring fading in.
- Sliders: thick 6dp track, 28dp thumb with shadow `e2`, value bubble springs up while dragging, detents tick with haptics.
- Toggles: custom pill switch, thumb travels with spring `snappy`.

### 4.6 Navigation
- **Bottom bar:** floating, detached pill (inset 16 from edges), `material.thin`, 3–4 items: Home · Inbox · Trips · You. Active item = filled icon + `accent` dot indicator that slides between items (shared position spring).
- **Top bar:** transparent over content; becomes `material.thin` with hairline once content scrolls under it.
- **Sheets:** primary navigation pattern for details/edits. Detents: peek (30%), half, full. Grabber 36×5, radius full.

### 4.7 Lists
Inset-grouped style: rows inside a rounded `bg.elevated` container on `bg.grouped`. Row height ≥ 52, leading 28dp tinted icon, hairline separators inset to text start.

### 4.8 Recipe Confirm Sheet (AI-built feature)
- Title: plain-language name.
- 1–3 sentence explanation in `body`, with `info` sparkle marker "Built from your request".
- Visual recipe: trigger → steps rendered as a vertical chain of small rounded nodes connected by a line that **draws itself** on appear.
- Editable values inline as chips (tap "100" → slider).
- Primary "Add to my app", tertiary "Change something".

### 4.9 Recipe Widgets (rendered from recipe `ui`)
`counter` (display number + soft progress ring), `chart` (rounded bars, no gridlines, accent bar for today), `list`, `timer` (ring countdown), `form`, `slider`, `toggle`, `map`, `card`, `search`, `gallery`. All follow the tokens above — the AI picks widget types, never styles.

### 4.10 Home-screen widgets (Glance)
Small/medium/large, radius follows system launcher mask, same tile language, live values roll on update.

---

## 5. Layout Principles

### 5.1 Spacing scale (dp)
`2 · 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 · 56 · 72`
- Screen side margin: **20**.
- Between cards: **12**. Between sections: **32**.
- Inside cards: **20**. Inside chips: 12 horizontal.

### 5.2 Grid
- Home: 2-column tile grid, gutter 12, tiles snap to 1×1 / 2×1.
- Content width capped at 600dp on large screens (centered), see §8.

### 5.3 Radii
`r.xs 8 · r.s 12 · r.m 16 · r.l 22 · r.xl 28 · r.xxl 36 · r.full`
- Nested rule: **inner radius = outer radius − padding** (keeps corners concentric).
- Use smooth/continuous corners (squircle shape implementation in designsystem), not plain circular arcs.

### 5.4 Whitespace philosophy
Whitespace is the primary design element. Prefer one hero element per screen (a big number, a map, an image). Secondary info lives one tap or one sheet away.

### 5.5 Iconography
- Single icon set: rounded, 1.75dp stroke, 24dp grid (e.g. Phosphor "regular"/"fill" or Lucide, OFL/ISC).
- Outline for inactive, filled for active/selected.
- Icons are never the only signifier for critical actions — pair with text.

---

## 6. Depth & Elevation

Depth comes from **blur + soft shadow + scale**, never heavy borders.

| Token | Light shadow | Dark treatment | Use |
|---|---|---|---|
| `e0` | none | none | Flat content |
| `e1` | 0 1 2 rgba(0,0,0,.04), 0 4 12 rgba(0,0,0,.04) | hairline `separator` border | Cards |
| `e2` | 0 4 12 rgba(0,0,0,.08), 0 12 32 rgba(0,0,0,.06) | `bg` +1 step + hairline | Floating buttons, sliders |
| `e3` | 0 12 32 rgba(0,0,0,.12), 0 24 64 rgba(0,0,0,.10) | +2 steps + 15% white top inner highlight | Lifted tiles, overlays, sheets |

### Materials (frosted glass)
- Use `RenderEffect` blur (API 31+) on content behind; fallback to opaque `material.thick` color on older devices.
- Glass surfaces get a 0.5dp top inner highlight (white @ 40% light / 12% dark) to read as physical.
- Never stack more than **two** blurred layers.

### Surface hierarchy (back → front)
canvas → cards → floating nav / prompt bar → sheets → overlays (on other apps) → toasts.

---

## 7. Overlays ({{PROJECT_NAME}}'s signature surfaces)

These appear **on top of other apps**, so they must be the most polished, least intrusive thing on screen.

### 7.1 Screenshot Bubble
- Appears from the right edge, vertically centered-low, 6 tags in a vertical pill stack on `material.thin`, `e3`.
- Enter: slide 24dp + fade + scale 0.92→1, spring `bouncy`, light haptic.
- Progress hairline along the bubble edge shows remaining time (4 s); touching pauses it.
- Tap tag → chip fills with tag tint, check mark draws, bubble collapses into a small "Saved" dot, then exits.
- Swipe away or ✕ → exits toward the edge with velocity.
- Never covers the center of the screen; never steals focus or the keyboard.

### 7.2 Floating Save Button (on Instagram reels)
- 52dp circle, `material.thin`, glyph 22dp, draggable, snaps to nearest edge with spring `gentle`.
- Idle after 3 s → shrinks to 36dp half-tucked into the edge at 70% opacity.
- Tap → morphs into a small horizontal pill "Saving…" → "Saved to Places" with the place name. Success haptic.

### 7.3 Block Screen (limit reached)
- Full-screen `material.thick` over the blocked app, content blurred behind (the user sees *where* they are, softly).
- Center: big `display` number ("100 reels"), one calm line ("That's your limit for today."), primary "Close Instagram", tertiary "Give me 5 more min" (requires a 10 s hold with a filling ring — friction by design).
- Enter: blur radius animates 0→40 while content scales from 1.04→1 (`gentle`). No alarming red, use `text.primary` and the focus tint.
- Always offers a way out (CLAUDE.md §21).

### 7.4 Pause Prompt (doomscroll breaker / "why am I opening this?")
- Bottom sheet style card over the app at half detent, 3–4 choice chips, a 10 s ring before "Continue" becomes active.

### 7.5 Toasts / Inline confirmations
- Top-center pill on `material.thin`, icon + one short line, auto-dismiss 2.5 s, swipe up to dismiss. Max one at a time; new ones replace with a crossfade.

---

## 8. Responsive Behavior

| Width | Behavior |
|---|---|
| < 360dp (compact phones) | Tiles 1-column for 2×1, side margin 16, display size 34 |
| 360–599dp (phones) | Default spec |
| 600–839dp (foldables, small tablets) | 3-column grid; list–detail split with sheets becoming side panes |
| ≥ 840dp | Max content width 600 for reading surfaces; grid up to 4 columns |

- Touch targets ≥ 48dp always.
- Landscape: sheets become centered cards (max 560 wide).
- Font scale up to 200%: tiles grow in height, numbers may wrap to new line, never truncate values.
- Edge-to-edge always; respect insets for gesture bar, cutouts, keyboard (prompt bar rides above IME with a spring).

---

## 9. Do's and Don'ts

### Do
- ✅ One hero element and one primary action per screen.
- ✅ Animate from the source: what you tapped becomes what opens.
- ✅ Use springs for everything that moves; tween only for opacity and color.
- ✅ Pair every important state change with a haptic.
- ✅ Show live data with rolling digits and status pills.
- ✅ Use blur to keep context visible behind overlays and sheets.
- ✅ Keep copy short, warm, human.
- ✅ Design dark mode with equal care — it's where overlays live at night.

### Don't
- ❌ No Material ripples, no default elevation shadows, no FABs, no snackbars.
- ❌ No linear easing, no animation longer than 500 ms for UI transitions.
- ❌ No more than one accent color on screen; no gradients on buttons.
- ❌ No sharp corners, no thick borders, no drop-shadow on text.
- ❌ No spinners when a skeleton/shimmer or optimistic UI works.
- ❌ No overlays that cover the center of another app (except Block Screen) or trap the user.
- ❌ No alarming reds for self-control features — be calm, not punishing.
- ❌ No emoji as UI icons; no stock-looking illustrations.
- ❌ Don't copy any specific company's brand assets, fonts or icons — the *feel* is premium, the identity is ours.

---

## 10. Motion System (the "smooth" part)

### 10.1 Spring tokens (Compose `spring(dampingRatio, stiffness)`)
| Token | Damping | Stiffness | Feel | Use |
|---|---|---|---|---|
| `snappy` | 0.85 | 800 | Quick, crisp | Toggles, chips, press states |
| `smooth` | 1.0 | 380 | No overshoot | Screen transitions, sheets |
| `gentle` | 0.9 | 220 | Soft settle | Overlays, edge snapping, blur-ins |
| `bouncy` | 0.7 | 450 | Small playful overshoot | Success moments, bubble enter, tile lift |
| `lazy` | 1.0 | 120 | Slow, ambient | Background parallax, progress rings |

Tweens (only opacity/color): `fade.fast 120ms`, `fade.base 200ms`, easing `cubic(0.2, 0, 0, 1)`.

### 10.2 Principles
1. **Interruptible:** every animation can be grabbed mid-flight and reversed (use `Animatable` + gesture velocity, never fire-and-forget).
2. **Velocity-aware:** flings carry release velocity into the spring.
3. **Spatial continuity:** shared elements and container transforms link where you came from and where you go.
4. **Choreography:** stagger list items 20–30 ms each, max 6 staggered; primary element leads, secondary follows.
5. **Scale is subtle:** 0.97 press, 1.03 lift, 0.92 enter. Never larger jumps.
6. **Performance:** 60/120 fps; animate `graphicsLayer` properties (translation, scale, alpha), not layout, wherever possible.

### 10.3 Transitions
| From → To | Motion |
|---|---|
| Tile → Feature screen | Container transform (shared bounds), `smooth`, icon/title/value as shared elements |
| List → Detail | Card expands to sheet/full, background scales to 0.94 + dims 20% |
| Open sheet | Slide up with `smooth`; content behind scales 0.96 and blurs |
| Dismiss sheet | Drag-follow 1:1, release with velocity → `gentle` |
| Tab switch | Crossfade 200 ms + 8dp vertical shift; indicator slides with `snappy` |
| Back (predictive back) | Screen shrinks to 0.9 with radius growing to `r.xl` following the gesture |

### 10.4 Signature moments
- **Prompt bar → Build sheet:** bar stretches into a full sheet (shared bounds), keyboard rises in sync; while AI works, a soft `info`-tinted aurora gradient drifts slowly behind the text (lazy spring, low opacity) — no spinner.
- **Feature born:** confirm sheet collapses into a new tile that flies to its grid slot, grid reflows around it with `bouncy`, success haptic.
- **Recipe chain draw:** connector line draws top→bottom (300 ms), nodes pop in with stagger.
- **Seat/price change:** status pill color morphs + digits roll; if worse (AVL→WL) a single gentle shake (2 cycles, 4dp).
- **Saved to Places:** card thumbnail shrinks into a pin that drops onto the map tab icon.

### 10.5 Rolling numbers
Each digit is a vertical column; changes roll up (increase) or down (decrease) with `snappy`, staggered right-to-left 15 ms. Tabular figures prevent width jitter.

### 10.6 Haptics map
| Event | Haptic |
|---|---|
| Button press | `ContextClick` / light tick |
| Toggle, chip select, slider detent | `ClockTick` |
| Long-press lift | `LongPress` |
| Success (saved, feature added) | `Confirm` |
| Limit reached / error | `Reject` |
| Drag snap to edge | light tick |

### 10.7 Loading
- Skeletons with a slow shimmer (1.2 s loop, low contrast) matching final layout.
- Optimistic UI for saves/tags: show success immediately, reconcile silently.
- AI work: aurora + rotating short status lines ("Reading the reel…", "Finding the place…").

### 10.8 Reduced motion
If system "remove animations" / reduced motion is on: replace springs with 150 ms fades, no parallax, no shake, no aurora; keep haptics.

---

## 11. Content & Microcopy
- Sentence case, short. Verbs on buttons ("Save place", "Watch this trip").
- Numbers first: "9 seats left" not "Seats remaining: 9".
- Friendly, never guilt-tripping: "That's 100 for today." not "You wasted 2 hours."
- AI-made content is always marked with the sparkle + "Built from your request".
- Indian formats: ₹ with Indian grouping (₹1,24,500), 12-hour time with am/pm, dates "Fri, 2 Oct".

---

## 12. Implementation Notes (Compose)
- `{{PROJECT_NAME}}Theme { }` provides `LocalColors`, `LocalType`, `LocalSpacing`, `LocalRadii`, `LocalElevation`, `LocalMotion`, `LocalHaptics`.
- Disable Material ripple globally (`LocalIndication` = custom scale+dim indication).
- Shared elements: `SharedTransitionLayout` + `Modifier.sharedBounds/sharedElement`.
- Blur: `Modifier.graphicsLayer { renderEffect = BlurEffect(...) }` (API 31+), fallback opaque material.
- Squircle: custom `Shape` in designsystem (`SmoothRoundedShape(radius, smoothing = 0.6)`).
- Overlays (`TYPE_APPLICATION_OVERLAY`) host a `ComposeView` with the same theme; keep them lightweight (no heavy images, no blur over other apps unless supported).
- Every component has a `@Preview` in light + dark + 200% font, and a screenshot test (Paparazzi/Roborazzi).

---

## 13. Agent Prompt Guide

### Quick reference
- Canvas `#F4F4F6` / `#000000` · Card `#FFFFFF` / `#141416` · Accent `#3D6BFF` / `#5B82FF`
- Text `#111114` / `#F5F5F7` · Secondary `#5E5E66` / `#A1A1AA`
- Success `#22B573` · Warning `#F2A93B` · Danger `#F04A4A` · AI `#8B6CFF`
- Font Inter (tabular numbers) · Radii 12/16/22/28 · Spacing 4-pt scale, margin 20
- Springs: snappy / smooth / gentle / bouncy / lazy

### Ready-to-use prompts
- *"Build `<Screen>` using {{PROJECT_NAME}}'s Still design system: tokens from `ui/designsystem` only, one hero element, one primary pill button, inset-grouped list below, large title that collapses on scroll, springs from `LocalMotion`, haptics from `LocalHaptics`, light + dark + 200% font previews."*
- *"Create an overlay component per DESIGN.md §7: `material.thin` glass, `e3` elevation, enters with `bouncy` from the nearest edge, auto-dismiss with a progress hairline, never covers screen center, always dismissible, haptic on show and on action."*
- *"Add a live status pill per §4.4 and §10.5: status color @14% background, rolling tabular digits, color morph on state change, single gentle shake when it gets worse."*
- *"Implement a container transform from a home tile to the feature screen per §10.3 using SharedTransitionLayout; icon, title and value are shared elements; background scales to 0.94 and dims."*

### Review checklist for any UI PR
- [ ] Only design tokens used (no raw dp/hex/sp)
- [ ] One accent, one primary action, ≤ 3 type sizes
- [ ] Springs for movement, interruptible, velocity-aware
- [ ] Haptics on meaningful changes
- [ ] Loading / empty / error / success states
- [ ] Light, dark, 200% font, reduced-motion verified
- [ ] Overlays dismissible and off-center
- [ ] Screenshot tests updated
