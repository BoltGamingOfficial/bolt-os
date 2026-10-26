#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ARCH="$(uname -m)"
BOLT_VERSION="${BOLT_VERSION:-0.1.0-dev}"
ARCHISO_PROFILE="${ARCHISO_PROFILE:-/usr/share/archiso/configs/releng}"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/out}"
WORK_DIR="${WORK_DIR:-$ROOT_DIR/work}"
PROFILE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/bolt-os-profile.XXXXXXXX")"

cleanup() {
  rm -rf -- "$PROFILE_DIR"
}
trap cleanup EXIT

if [[ "$ARCH" != "x86_64" ]]; then
  printf 'BOLT OS prototype currently targets x86_64; detected: %s\n' "$ARCH" >&2
  exit 1
fi
if ! command -v mkarchiso >/dev/null 2>&1; then
  printf 'mkarchiso not found. On Arch Linux, install: sudo pacman -S archiso\n' >&2
  exit 1
fi
if [[ ! -d "$ARCHISO_PROFILE" ]]; then
  printf 'Archiso releng profile not found at: %s\n' "$ARCHISO_PROFILE" >&2
  printf 'Install archiso or set ARCHISO_PROFILE to a valid releng profile.\n' >&2
  exit 1
fi

mkdir -p "$OUT_DIR"
cp -a "$ARCHISO_PROFILE/." "$PROFILE_DIR/"

# Keep upstream boot configuration and tools, changing only BOLT metadata.
sed -i -E 's/^iso_name=.*/iso_name="bolt-os"/' "$PROFILE_DIR/profiledef.sh"
sed -i -E 's/^iso_label=.*/iso_label="BOLT_OS"/' "$PROFILE_DIR/profiledef.sh"
sed -i -E 's|^iso_publisher=.*|iso_publisher="BOLT-GAMING"| ' "$PROFILE_DIR/profiledef.sh"
sed -i -E 's/^iso_application=.*/iso_application="BOLT OS Live Prototype"/' "$PROFILE_DIR/profiledef.sh"
sed -i -E "s/^iso_version=.*/iso_version=\"$BOLT_VERSION\"/" "$PROFILE_DIR/profiledef.sh"
sed -i -E 's/^install_dir=.*/install_dir="bolt"/' "$PROFILE_DIR/profiledef.sh"

PKG_FILE="$PROFILE_DIR/packages.$ARCH"
if [[ ! -f "$PKG_FILE" ]]; then
  PKG_FILE="$PROFILE_DIR/packages.arch"
fi
if [[ ! -f "$PKG_FILE" ]]; then
  printf 'Could not find the package list in the supplied Archiso profile.\n' >&2
  exit 1
fi

# Union the upstream live-image packages with BOLT's explicitly listed set.
# Sort and de-duplicate to avoid duplicate pacman targets.
TMP_PACKAGES="$(mktemp)"
grep -hEv '^[[:space:]]*(#|$)' "$PKG_FILE" "$ROOT_DIR/packages.x86_64" |
  LC_ALL=C sort -u > "$TMP_PACKAGES"
cat "$TMP_PACKAGES" > "$PKG_FILE"
rm -f -- "$TMP_PACKAGES"

# Steam and its 32-bit Vulkan dependencies live in multilib.
if grep -q '^#\[multilib\]' "$PROFILE_DIR/pacman.conf"; then
  sed -i '/^#\[multilib\]/,/^$/ s/^#//' "$PROFILE_DIR/pacman.conf"
elif ! grep -q '^\[multilib\]' "$PROFILE_DIR/pacman.conf"; then
  cat >> "$PROFILE_DIR/pacman.conf" <<'EOF'

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF
fi

# Apply BOLT's live-session configuration over the upstream profile.
if [[ -d "$ROOT_DIR/airootfs" ]]; then
  mkdir -p "$PROFILE_DIR/airootfs"
  cp -a "$ROOT_DIR/airootfs/." "$PROFILE_DIR/airootfs/"
fi

# Generate systemd enablement links inside the profile so the live session
# starts networking, Bluetooth, and the KDE display manager.
mkdir -p "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants"
ln -sfn /usr/lib/systemd/system/NetworkManager.service \
  "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/NetworkManager.service"
ln -sfn /usr/lib/systemd/system/bluetooth.service \
  "$PROFILE_DIR/airootfs/etc/systemd/system/multi-user.target.wants/bluetooth.service"
ln -sfn /usr/lib/systemd/system/sddm.service \
  "$PROFILE_DIR/airootfs/etc/systemd/system/display-manager.service"

# The live user's passwordless sudo rule is intentionally limited to the
# ephemeral live environment, never copied by an installer to a disk system.
if grep -q '^file_permissions=(' "$PROFILE_DIR/profiledef.sh"; then
  sed -i '/^)/i\  ["/etc/sudoers.d/10-bolt-live"]="0:0:440"' "$PROFILE_DIR/profiledef.sh"
fi

printf 'Building BOLT OS %s from Archiso profile: %s\n' "$BOLT_VERSION" "$ARCHISO_PROFILE"
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"

printf '\nBuild completed. Output files:\n'
find "$OUT_DIR" -maxdepth 1 -type f -printf '%f (%s bytes)\n' | sort
