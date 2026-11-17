#!/usr/bin/env bash
# Run `make check` before Claude ends a turn. Receives hook JSON on stdin.
# Exits 2 (Claude keeps working and sees the errors) while checks fail.
# Skips when nothing changed since the last green run, and lets Claude stop after
# 3 blocked attempts in a row so a check it can't fix never loops forever.
set -uo pipefail

INPUT=$(cat)
ROOT="${CLAUDE_PROJECT_DIR:-.}"
cd "$ROOT" || exit 0
grep -q '^check:' Makefile 2>/dev/null || exit 0
git rev-parse --git-dir >/dev/null 2>&1 || exit 0

SESSION=$(printf '%s' "$INPUT" | jq -r '.session_id // "default"' 2>/dev/null || echo default)
STATE="${TMPDIR:-/tmp}/claude-stop-check-$(pwd | cksum | cut -d' ' -f1)"
mkdir -p "$STATE"
BLOCKS="$STATE/blocks-$SESSION"

# Fingerprint of HEAD + working tree, so an unchanged tree isn't re-checked every turn.
FP=$({
  git rev-parse HEAD 2>/dev/null
  git diff HEAD 2>/dev/null
  git ls-files --others --exclude-standard -z | xargs -0 git hash-object 2>/dev/null
} | cksum)
[ "$(cat "$STATE/green" 2>/dev/null)" = "$FP" ] && exit 0

if OUT=$(make check 2>&1); then
  echo "$FP" > "$STATE/green"
  rm -f "$BLOCKS"
  exit 0
fi

N=$(( $(cat "$BLOCKS" 2>/dev/null || echo 0) + 1 ))
if [ "$N" -gt 3 ]; then
  rm -f "$BLOCKS"
  echo '{"systemMessage": "make check is still failing — Claude was asked to report why."}'
  exit 0
fi
echo "$N" > "$BLOCKS"

{
  echo "make check failed — fix the cause before finishing (never weaken a rule or add a suppression to get green)."
  [ "$N" -eq 3 ] && echo "Last attempt: if you can't fix it, tell the user plainly what fails and why, and add it to docs/PROGRESS.md Known Issues."
  echo "--- last 60 lines ---"
  printf '%s\n' "$OUT" | tail -n 60
} >&2
exit 2
