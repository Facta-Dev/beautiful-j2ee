#!/usr/bin/env bash
# check-build.sh — compile and run the self-checking Java example.
# A missing JDK is a visible SKIP, never a silent pass; CI installs it.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

if ! command -v javac >/dev/null 2>&1; then
  echo "check-build: SKIP — javac not found (CI runs it)"
  exit 0
fi

BUILD="${TMPDIR:-/tmp}/beautiful-j2ee-build"
mkdir -p "$BUILD"
javac -d "$BUILD" examples/minimal/src/example/*.java
java -cp "$BUILD" example.SelfCheck
echo "check-build: OK"
