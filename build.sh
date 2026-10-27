#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
ARCH="$(uname -m)"
BOLT_VERSION="${BOLT_VERSION:-0.1.0-dev}"
BOLT_ENABLE_BLUETOOTH="${BOLT_ENABLE_BLUETOOTH:-0}"
ARCHISO_PROFILE="${ARCHISO_PROFILE:-/usr/share/archiso/configs/releng}"
OUT_DIR="${OUT_DIR:-$ROOT_DIR/out}"
WORK_DIR="${WORK_DIR:-$ROOT_DIR/work}"
PROFILE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/bolt-os-profile.XXXXXXXX")"

cleanup() {
  rm -rf -- "$PROFILE_DIR"
}
trap cleanup EXIT

if [[ ! "$BOLT_VERSION" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]]; then
  printf 'Invalid BOLT_VERSION: use only letters, numbers, dot, underscore, and hyphen.\n' >&2
  exit 2
fi
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

# Keep upstream boot configuration and tools, changing BOLT metadata only.
sed -i -E 's/^iso_name=.*/iso_name="bolt-os"/' "$PROFILE_DIR/profiledef.sh"
sed -i -E 's/^iso_label=.*/iso_label="BOLT_OS"/' "$PROFILE_DIR/profiledef.sh"
sed -i -E 's|^iso_publisher=.*|iso_publisher="BOLT-GAMING"|' "$PROFILE_DIR/profiledef.sh"
sed -i -E 's/^iso_application=.*/iso_application="BOLT OS Live Prototype"/' "$PROFILE_DIR/profiledef.sh"
sed -i -E "s/^iso_version=.*/iso_version=\"$BOLT_VERSION\"/" "$PROFILE_DIR/profiledef.sh"
sed -i -E 's/^install_dir=.*/install_dir="bolt"/' "$PROFILE_DIR/profiledef.sh"

PKG_FILE="$PROFILE_DIR/packages.$ARCH"
if [[ ! -f "$PKG_FILE" ]]; then
  printf 'Could not find packages.%s in the supplied Archiso profile.\n' "$ARCH" >&2
  exit 1
fi

# Union upstream live-image utilities with BOLT's desktop and gaming set.
# Sorting and de-duplicating prevents duplicate pacman targets.
TMP_PACKAGES="$(mktemp)"
grep -hEv '^[[:space:]]*(#|$)' "$PKG_FILE" "$ROOT_DIR/packages.x86_64" |
  LC_ALL=C sort -u > "$TMP_PACKAGES"
cat "$TMP_PACKAGES" > "$PKG_FILE"
rm -f -- "$TMP_PACKAGES"

# Steam and its 32-bit Vulkan dependencies are in multilib.
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

# Ensure repository-created scripts have executable mode in the ISO overlay.
if [[ -f "$PROFILE_DIR/airootfs/usr/local/bin/bolt-preset" ]]; then
  chmod 0755 "$PROFILE_DIR/airootfs/usr/local/bin/bolt-preset"
fi

# Ship the repeatable VM smoke-test script with the live image for easy diagnostics.
if [[ -f "$ROOT_DIR/tests/vm-smoke-test.sh" ]]; then
  install -D -m 0755 "$ROOT_DIR/tests/vm-smoke-test.sh" \
    "$PROFILE_DIR/airootfs/usr/local/share/bolt-os/tests/vm-smoke-test.sh"
fi

# Include the simple, high-contrast BOLT wallpaper in the live image.
if [[ -f "$ROOT_DIR/branding/bolt-wallpaper.svg" ]]; then
  mkdir -p "$PROFILE_DIR/airootfs/usr/share/wallpapers"
  install -m 0644 "$ROOT_DIR/branding/bolt-wallpaper.svg" \
    "$PROFILE_DIR/airootfs/usr/share/wallpapers/BOLT.svg"
fi

# Use NetworkManager in the KDE session rather than running two network
# managers in parallel. The upstream ISO links systemd-networkd/resolved.
SYSTEMD_TREE="$PROFILE_DIR/airootfs/etc/systemd/system"
mkdir -p "$SYSTEMD_TREE/multi-user.target.wants"
find "$SYSTEMD_TREE" -type l \( -name 'systemd-networkd.service' \
  -o -name 'systemd-resolved.service' \
  -o -name 'systemd-networkd-wait-online.service' \) -delete
rm -f "$PROFILE_DIR/airootfs/etc/resolv.conf"
ln -s /run/NetworkManager/resolv.conf "$PROFILE_DIR/airootfs/etc/resolv.conf"

# Enable only the services needed to start the live desktop smoothly.
ln -sfn /usr/lib/systemd/system/NetworkManager.service \
  "$SYSTEMD_TREE/multi-user.target.wants/NetworkManager.service"
# Provide the supported system power-profile API for BOLT preset selection.
ln -sfn /usr/lib/systemd/system/power-profiles-daemon.service \
  "$SYSTEMD_TREE/multi-user.target.wants/power-profiles-daemon.service"
# VirtualBox guest utilities improve VM integration. This is harmless on
# physical hardware; the service will use the guest driver when available.
ln -sfn /usr/lib/systemd/system/vboxservice.service \
  "$SYSTEMD_TREE/multi-user.target.wants/vboxservice.service"
if [[ "$BOLT_ENABLE_BLUETOOTH" == "1" ]]; then
  ln -sfn /usr/lib/systemd/system/bluetooth.service \
    "$SYSTEMD_TREE/multi-user.target.wants/bluetooth.service"
elif [[ "$BOLT_ENABLE_BLUETOOTH" != "0" ]]; then
  printf 'Invalid BOLT_ENABLE_BLUETOOTH: use 0 (default) or 1.\n' >&2
  exit 2
fi
ln -sfn /etc/systemd/system/bolt-live-user.service \
  "$SYSTEMD_TREE/multi-user.target.wants/bolt-live-user.service"
mkdir -p "$SYSTEMD_TREE/graphical.target.wants"
ln -sfn /usr/lib/systemd/system/sddm.service \
  "$SYSTEMD_TREE/graphical.target.wants/sddm.service"
ln -sfn /usr/lib/systemd/system/sddm.service \
  "$SYSTEMD_TREE/display-manager.service"

# Set the passwordless sudo rule's required restrictive permissions. It is
# present only on the ephemeral live image and is not a disk-install policy.
if grep -q '^file_permissions=(' "$PROFILE_DIR/profiledef.sh"; then
  sed -i '/^)/i\  ["/etc/sudoers.d/10-bolt-live"]="0:0:440"' "$PROFILE_DIR/profiledef.sh"
fi

printf 'Building BOLT OS %s from Archiso profile: %s\n' "$BOLT_VERSION" "$ARCHISO_PROFILE"
mkarchiso -v -w "$WORK_DIR" -o "$OUT_DIR" "$PROFILE_DIR"

mapfile -t ISO_FILES < <(find "$OUT_DIR" -maxdepth 1 -type f -name '*.iso' -printf '%f\n' | sort)
if (("${#ISO_FILES[@]}" == 0)); then
  printf 'Build command returned successfully but no ISO was found in %s.\n' "$OUT_DIR" >&2
  exit 1
fi
(
  cd "$OUT_DIR"
  : > SHA256SUMS
  for iso in "${ISO_FILES[@]}"; do
    sha256sum "$iso" >> SHA256SUMS
  done
)

printf '\nBuild completed. Output files:\n'
find "$OUT_DIR" -maxdepth 1 -type f -printf '%f (%s bytes)\n' | sort
