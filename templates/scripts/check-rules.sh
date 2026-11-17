#!/usr/bin/env bash
# Repo-wide rules no single linter covers. Part of `make check`, pre-commit and CI.
#  1. Every TODO/FIXME/HACK links an issue:  TODO(#123): …  or  TODO(https://…): …
#  2. Suppressions (noqa, type: ignore, @ts-expect-error, eslint-disable, @Suppress, …)
#     never grow past the count in .suppressions-baseline.
# Usage: scripts/check-rules.sh             check
#        scripts/check-rules.sh --update    rewrite the baseline (a human decision; review the diff)
set -euo pipefail
cd "$(git rev-parse --show-toplevel)"

# Paths the rules skip: generated and vendored code, docs. Setup adapts this list to the stacks.
EXCLUDE=(':!scripts/check-rules.sh' ':!*.md' ':!**/generated/**' ':!**/*.lock' ':!**/*-lock.*')

SUPPRESS='noqa|type: *ignore|pyright: *ignore|pragma: *no cover|@ts-ignore|@ts-expect-error|@ts-nocheck|eslint-disable|biome-ignore|istanbul ignore|c8 ignore|@Suppress|@SuppressWarnings|ktlint-disable|swiftlint:disable|nolint|#\[allow\(|ignore_for_file|// ignore:|NOSONAR|nosec'

BASELINE_FILE=.suppressions-baseline
count=$( (git grep --untracked -cE "$SUPPRESS" -- . "${EXCLUDE[@]}" 2>/dev/null || true) | awk -F: '{s += $NF} END {print s + 0}')

if [ "${1:-}" = "--update" ]; then
  echo "$count" > "$BASELINE_FILE"
  echo "Suppression baseline set to $count. Commit it with the reason in the message."
  exit 0
fi

status=0

todos=$( (git grep --untracked -nwE 'TODO|FIXME|HACK' -- . "${EXCLUDE[@]}" 2>/dev/null || true) \
  | grep -vE '(TODO|FIXME|HACK)\((#[0-9]+|https?://[^)]+)\)' || true)
if [ -n "$todos" ]; then
  echo "TODO/FIXME/HACK without an issue link. Write it as TODO(#123): … — or do the work now:"
  echo "$todos"
  status=1
fi

baseline=$(cat "$BASELINE_FILE" 2>/dev/null || echo 0)
if [ "$count" -gt "$baseline" ]; then
  echo "Suppressions grew from $baseline to $count. Fix the cause instead of silencing the check."
  echo "If one is truly unavoidable, give it a reason on the same line and ask the user to run"
  echo "scripts/check-rules.sh --update. Current suppressions:"
  git grep --untracked -nE "$SUPPRESS" -- . "${EXCLUDE[@]}" || true
  status=1
elif [ "$count" -lt "$baseline" ]; then
  echo "Suppressions dropped from $baseline to $count — run scripts/check-rules.sh --update to lock that in."
fi

exit $status
