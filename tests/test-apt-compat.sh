#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/rootfs-overlay/usr/local/bin/apt"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT
mkdir -p "$TMP_DIR/bin"
export BOLT_APT_TEST_LOG="$TMP_DIR/commands.log"
cat > "$TMP_DIR/bin/pacman" <<'STUB'
#!/usr/bin/env bash
printf 'pacman\n' >> "$BOLT_APT_TEST_LOG"
printf '%s\n' "$@" >> "$BOLT_APT_TEST_LOG"
STUB
cat > "$TMP_DIR/bin/sudo" <<'STUB'
#!/usr/bin/env bash
exec "$@"
STUB
chmod +x "$TMP_DIR/bin/pacman" "$TMP_DIR/bin/sudo"
export PATH="$TMP_DIR/bin:$PATH"

assert_call() {
  local expected="$*"
  local actual
  local -a captured=()
  mapfile -t captured < "$BOLT_APT_TEST_LOG"
  actual="${captured[*]}"
  if [[ "$actual" != "$expected" ]]; then
    printf 'Expected: %s\nActual:   %s\n' "$expected" "$actual" >&2
    return 1
  fi
}

: > "$BOLT_APT_TEST_LOG"
"$SCRIPT" install --yes firefox
assert_call pacman -Syu --needed --noconfirm firefox

: > "$BOLT_APT_TEST_LOG"
"$SCRIPT" search prism
assert_call pacman -Ss prism

: > "$BOLT_APT_TEST_LOG"
"$SCRIPT" remove --assume-yes firefox
assert_call pacman -Rns --noconfirm firefox

"$SCRIPT" help >/dev/null
printf 'PASS: apt-style commands translate to safe pacman operations\n'
