#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_FILE="$ROOT_DIR/packages.x86_64"
BUILD_FILE="$ROOT_DIR/build.sh"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

[[ -s "$PKG_FILE" ]] || fail "packages.x86_64 is missing or empty"
[[ -s "$BUILD_FILE" ]] || fail "build.sh is missing or empty"
[[ -s "$ROOT_DIR/tests/vm-smoke-test.sh" ]] || fail "VM smoke test script is missing or empty"
grep -Fq '/usr/local/share/bolt-os/tests/vm-smoke-test.sh' "$BUILD_FILE" || fail "build.sh must install the VM smoke test into the live image"
bash -n "$BUILD_FILE" || fail "build.sh has a Bash syntax error"

# Ignore comments and blank lines, then detect duplicate package entries.
duplicates="$(grep -hEv '^[[:space:]]*(#|$)' "$PKG_FILE" | LC_ALL=C sort | uniq -d)"
[[ -z "$duplicates" ]] || fail "duplicate package entries: $duplicates"

for package in base linux linux-firmware networkmanager firefox plasma-desktop sddm mesa vulkan-icd-loader steam gamemode; do
  grep -Fxq "$package" "$PKG_FILE" || fail "required package missing: $package"
done

# shellcheck disable=SC2016
grep -Fq 'BOLT_ENABLE_BLUETOOTH="${BOLT_ENABLE_BLUETOOTH:-0}"' "$BUILD_FILE" ||
  fail "Bluetooth must default to opt-in"
grep -Fq 'BOLT_ENABLE_BLUETOOTH=1' "$ROOT_DIR/BUILDING.md" ||
  fail "BUILDING.md must document the Bluetooth opt-in"

printf 'PASS: manifest, required packages, build syntax, and Bluetooth policy checks\n'
