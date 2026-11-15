#!/usr/bin/env bash
# Auto-format + lint the file Claude just edited. Receives hook JSON on stdin.
# Never blocks when a tool is missing; exits 2 (feedback to Claude) on real lint errors.
# Setup step adapts the per-language commands to this project's stacks.
set -uo pipefail

FILE=$(jq -r '.tool_input.file_path // empty' 2>/dev/null)
[ -z "$FILE" ] && exit 0
[ -f "$FILE" ] || exit 0
ROOT="${CLAUDE_PROJECT_DIR:-.}"
cd "$ROOT" || exit 0

fail() { echo "$1 found issues in $FILE — fix them before continuing." >&2; exit 2; }

case "$FILE" in
  *.py)
    if command -v uv >/dev/null 2>&1; then
      uv run --quiet ruff format "$FILE" >/dev/null 2>&1
      uv run --quiet ruff check --fix "$FILE" 2>&1 || fail "ruff"
    fi ;;
  *.kt|*.kts)
    if command -v ktlint >/dev/null 2>&1; then
      ktlint -F "$FILE" >/dev/null 2>&1
      ktlint "$FILE" 2>&1 || fail "ktlint"
    fi ;;
  *.ts|*.tsx|*.js|*.jsx|*.mjs|*.cjs)
    if [ -x node_modules/.bin/prettier ] || command -v npx >/dev/null 2>&1; then
      npx --no-install prettier --write "$FILE" >/dev/null 2>&1
      npx --no-install eslint --fix "$FILE" 2>&1 || fail "eslint"
    fi ;;
  *.swift)
    if command -v swiftformat >/dev/null 2>&1; then
      swiftformat "$FILE" >/dev/null 2>&1
    fi
    if command -v swiftlint >/dev/null 2>&1; then
      swiftlint lint --quiet --path "$FILE" 2>&1 || fail "swiftlint"
    fi ;;
  *.go)
    command -v gofmt >/dev/null 2>&1 && gofmt -w "$FILE" ;;
  *.rs)
    command -v rustfmt >/dev/null 2>&1 && rustfmt "$FILE" ;;
  *.dart)
    command -v dart >/dev/null 2>&1 && dart format "$FILE" >/dev/null 2>&1 ;;
esac
exit 0
