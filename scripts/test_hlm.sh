#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HLM="$ROOT_DIR/scripts/hlm"
PASS=0
FAIL=0

assert_eq() {
  local desc="$1" expected="$2" actual="$3"
  if [ "$expected" = "$actual" ]; then
    PASS=$((PASS + 1))
  else
    echo "FAIL: $desc (expected '$expected', got '$actual')" >&2
    FAIL=$((FAIL + 1))
  fi
}

assert_contains() {
  local desc="$1" needle="$2" haystack="$3"
  if printf '%s' "$haystack" | grep -qF "$needle"; then
    PASS=$((PASS + 1))
  else
    echo "FAIL: $desc (missing '$needle')" >&2
    FAIL=$((FAIL + 1))
  fi
}

# 1. version command
out="$("$HLM" version)"
assert_contains "version outputs hlm" "hlm " "$out"
assert_contains "version outputs 1.2.0" "1.2.0" "$out"

# 2. help command has grouped sections
help_out="$(NO_COLOR=1 "$HLM" help)"
assert_contains "help has Lifecycle" "Lifecycle:" "$help_out"
assert_contains "help has Diagnostics" "Diagnostics:" "$help_out"
assert_contains "help has doctor" "doctor" "$help_out"

# 3. doctor command runs and checks config.yaml
doc_out="$(NO_COLOR=1 "$HLM" doctor || true)"
assert_contains "doctor checks config.yaml" "config.yaml" "$doc_out"

# 4. unknown command exits 1
set +e
err_out="$("$HLM" not-a-real-cmd 2>&1)"
rc=$?
set -e
assert_eq "unknown command exits 1" "1" "$rc"
assert_contains "unknown command message" "Unknown command" "$err_out"

# 5. restore without arg exits 1
set +e
res_out="$("$HLM" restore 2>&1)"
rc=$?
set -e
assert_eq "restore without arg exits 1" "1" "$rc"
assert_contains "restore usage message" "Usage: hlm restore" "$res_out"

# 6. symlinked invocation resolves ROOT_DIR
TMP_LINK="/tmp/hlm-test-link-$$"
ln -sf "$HLM" "$TMP_LINK"
sym_out="$(cd /tmp && "$TMP_LINK" version)"
rm -f "$TMP_LINK"
assert_contains "symlinked version works" "1.2.0" "$sym_out"

echo "Passed: $PASS, Failed: $FAIL"
[ "$FAIL" -eq 0 ]
