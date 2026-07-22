#!/usr/bin/env bash
#
# check-style.sh — keep every Kestrel source in this repo formatted and lint-clean
# against a real `kestrel` binary. This is the source-hygiene gate (distinct from
# verified/verify.sh, which proves the released compiler runs the examples).
#
#   - `kestrel fmt --check` must pass for every .kst (text-based; works on files
#     that intentionally don't compile yet, e.g. `Status: designed` examples).
#   - `kestrel lint` must report no lints for every .kst that PARSES; files that
#     don't parse are skipped (their lints can't be computed).
#
# Usage:
#   KESTREL=/path/to/kestrel ./check-style.sh   # or `kestrel` from PATH
set -uo pipefail

KESTREL="${KESTREL:-kestrel}"
cd "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
command -v "$KESTREL" >/dev/null 2>&1 || { echo "missing: $KESTREL" >&2; exit 2; }

mapfile -t files < <(find . -name '*.kst' | sort)
fmt_fail=0
lint_fail=0
skipped=0

echo "== kestrel fmt --check (${#files[@]} files) =="
for f in "${files[@]}"; do
  if ! "$KESTREL" fmt --check "$f" >/dev/null 2>&1; then
    echo "  needs formatting: $f"
    fmt_fail=$((fmt_fail + 1))
  fi
done

echo "== kestrel lint =="
for f in "${files[@]}"; do
  # `compile-fail/` holds deliberately malformed programs (empty bodies, bad
  # types) that exist to be *rejected* — linting them is noise.
  case "$f" in
    */compile-fail/*) continue ;;
  esac
  out="$("$KESTREL" lint "$f" 2>&1)"
  if grep -q "parse errors" <<<"$out"; then
    skipped=$((skipped + 1))
    continue
  fi
  if grep -q "lint(s) found" <<<"$out"; then
    grep -vE "lint\(s\) found|No lints" <<<"$out" | sed 's/^/  /'
    lint_fail=$((lint_fail + 1))
  fi
done

echo "----"
echo "unformatted: $fmt_fail | files with lints: $lint_fail | unparseable (lint skipped): $skipped"
if [ "$fmt_fail" -eq 0 ] && [ "$lint_fail" -eq 0 ]; then
  echo "style OK"
  exit 0
fi
exit 1
