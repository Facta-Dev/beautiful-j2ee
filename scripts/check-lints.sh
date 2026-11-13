#!/usr/bin/env bash
# check-lints.sh — prove the drop-in Checkstyle config fires.
# The clean control must stay quiet; the violation harness must fail.
# A missing checkstyle is a visible SKIP, never a silent pass; CI installs it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v checkstyle >/dev/null 2>&1; then
  echo "check-lints: SKIP checkstyle — not installed (CI runs it)"
  exit 0
fi

if checkstyle -c lints/checkstyle.xml lints/check/Clean.java >/tmp/checkstyle-clean.log 2>&1; then
  echo "check-lints: clean control is quiet"
else
  cat /tmp/checkstyle-clean.log >&2
  echo "check-lints: FAIL — the clean control reported a finding" >&2
  exit 1
fi

if checkstyle -c lints/checkstyle.xml lints/check/Violations.java >/tmp/checkstyle-violations.log 2>&1; then
  echo "check-lints: FAIL — the violation harness stayed quiet" >&2
  exit 1
fi

echo "check-lints: violation harness fired; OK"
