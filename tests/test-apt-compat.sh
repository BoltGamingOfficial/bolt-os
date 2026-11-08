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
: > "$BOLT_APT_TEST_LOG"
"$SCRIPT" install --yes firefox
printf 'pacman\n-Syu\n--needed\n--noconfirm\nfirefox\n' > "$TMP_DIR/expected"
diff -u "$TMP_DIR/expected" "$BOLT_APT_TEST_LOG"
: > "$BOLT_APT_TEST_LOG"
"$SCRIPT" search prism
printf 'pacman\n-Ss\nprism\n' > "$TMP_DIR/expected"
diff -u "$TMP_DIR/expected" "$BOLT_APT_TEST_LOG"
: > "$BOLT_APT_TEST_LOG"
"$SCRIPT" remove --assume-yes firefox
printf 'pacman\n-Rns\n--noconfirm\nfirefox\n' > "$TMP_DIR/expected"
diff -u "$TMP_DIR/expected" "$BOLT_APT_TEST_LOG"
"$SCRIPT" help >/dev/null
printf 'PASS: apt-style commands translate to safe pacman operations\n'
