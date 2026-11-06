#!/usr/bin/env bash
set -Eeuo pipefail

ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
BOLT_VERSION="${BOLT_VERSION:-0.2.0-dev}"
DELIVERY_DIR="${DELIVERY_DIR:-$ROOT_DIR/BOLT-OS-DELIVERY}"
WORK_DIR="${WORK_DIR:-$DELIVERY_DIR/work}"
ROOTFS="$WORK_DIR/rootfs"
ISO_ROOT="$WORK_DIR/iso-root"
PACMAN_CONF="$WORK_DIR/pacman-bolt.conf"
BUILD_LOG="$DELIVERY_DIR/logs/build.log"
ISO_NAME="BOLT-OS-${BOLT_VERSION}-x86_64.iso"
ISO_PATH="$DELIVERY_DIR/iso/$ISO_NAME"

fail() {
  printf 'FAIL: %s\n' "$*" >&2
  exit 1
}

log() {
  printf '\n[%s] %s\n' "$(date -Is)" "$*"
}

mkdir -p "$DELIVERY_DIR/iso" "$DELIVERY_DIR/checksums" "$DELIVERY_DIR/logs" "$DELIVERY_DIR/testing" "$WORK_DIR"
exec > >(tee "$BUILD_LOG") 2>&1

[[ "$BOLT_VERSION" =~ ^[A-Za-z0-9][A-Za-z0-9._-]*$ ]] || fail 'invalid BOLT_VERSION'
[[ "$(uname -m)" == x86_64 ]] || fail 'the supported target is UEFI x86_64'
[[ "$EUID" -eq 0 ]] || fail 'run this build as root on a current x86_64 Arch Linux host'
[[ -r /etc/os-release ]] || fail '/etc/os-release is missing'
# shellcheck disable=SC1091
source /etc/os-release
[[ "${ID:-}" == arch ]] || fail 'builds must run on an Arch Linux host (not a compatibility container with different tooling)'

required_tools=(pacman pacstrap arch-chroot mkinitcpio mksquashfs xorriso limine shellcheck sha256sum awk grep sort find du install getconf)
for tool in "${required_tools[@]}"; do
  command -v "$tool" >/dev/null 2>&1 || fail "required build tool is missing: $tool"
done
[[ -r /etc/pacman.conf ]] || fail '/etc/pacman.conf is missing'
[[ -r /etc/pacman.d/mirrorlist ]] || fail '/etc/pacman.d/mirrorlist is missing'

log "Starting BOLT OS $BOLT_VERSION build on $(uname -m)"
"$ROOT_DIR/tests/check-source.sh"
"$ROOT_DIR/tests/test-first-run.sh"
"$ROOT_DIR/tests/test-bolt-preset.sh"
shellcheck "$ROOT_DIR/build.sh" "$ROOT_DIR/tests/"*.sh \
  "$ROOT_DIR/rootfs-overlay/usr/local/bin/bolt-preset" \
  "$ROOT_DIR/rootfs-overlay/usr/local/libexec/bolt-first-run" \
  "$ROOT_DIR/rootfs-overlay/usr/local/libexec/bolt-set-wallpaper-once" \
  "$ROOT_DIR/mkinitcpio/install/bolt_live" "$ROOT_DIR/mkinitcpio/hooks/bolt_live"
log 'Build host package database refresh; no packages are upgraded on the host.'
cat > "$PACMAN_CONF" <<'PACMAN'
[options]
Architecture = auto
Color
CheckSpace
ParallelDownloads = 5
SigLevel = Required DatabaseOptional
LocalFileSigLevel = Optional

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
PACMAN
pacman --config "$PACMAN_CONF" -Sy --noconfirm

mapfile -t PACKAGES < <(grep -Ev '^[[:space:]]*(#|$)' "$ROOT_DIR/packages.x86_64")
((${#PACKAGES[@]} > 0)) || fail 'package manifest is empty'
for package in "${PACKAGES[@]}"; do
  [[ "$package" =~ ^[a-zA-Z0-9@._+-]+$ ]] || fail "invalid package name in manifest: $package"
  pacman --config "$PACMAN_CONF" -Si "$package" >/dev/null || fail "package is not available from enabled official repositories: $package"
done
log "Validated ${#PACKAGES[@]} package names against the enabled official repositories."

rm -rf -- "$ROOTFS" "$ISO_ROOT"
mkdir -p "$ROOTFS" "$ISO_ROOT/BOLT/boot" "$ISO_ROOT/boot/limine" "$ISO_ROOT/EFI/BOOT"

log 'Installing the minimal system to the isolated root filesystem.'
pacstrap -K -C "$PACMAN_CONF" "$ROOTFS" "${PACKAGES[@]}"

log 'Applying BOLT root filesystem overlay and first-boot policy.'
cp -a "$ROOT_DIR/rootfs-overlay/." "$ROOTFS/"
install -D -m 0644 "$ROOT_DIR/branding/bolt-wallpaper.svg" "$ROOTFS/usr/share/wallpapers/BOLT.svg"
install -D -m 0644 "$ROOT_DIR/branding/bolt-logo.svg" "$ROOTFS/usr/share/pixmaps/bolt-logo.svg"
install -D -m 0755 "$ROOT_DIR/tests/vm-smoke-test.sh" "$ROOTFS/usr/local/share/bolt-os/tests/vm-smoke-test.sh"
install -m 0644 "$PACMAN_CONF" "$ROOTFS/etc/pacman.conf"
install -D -m 0644 "$ROOT_DIR/mkinitcpio/bolt-live.conf" "$ROOTFS/etc/mkinitcpio.conf"
install -D -m 0755 "$ROOT_DIR/mkinitcpio/install/bolt_live" "$ROOTFS/etc/initcpio/install/bolt_live"
install -D -m 0644 "$ROOT_DIR/mkinitcpio/hooks/bolt_live" "$ROOTFS/etc/initcpio/hooks/bolt_live"
chmod 0440 "$ROOTFS/etc/sudoers.d/10-bolt-wheel"

cat > "$ROOTFS/etc/hostname" <<'HOST'
bolt-os
HOST
cat > "$ROOTFS/etc/issue" <<'ISSUE'
BOLT OS \n \l
ISSUE
cat > "$ROOTFS/etc/hosts" <<'HOSTS'
127.0.0.1 localhost
::1       localhost
127.0.1.1 bolt-os.localdomain bolt-os
HOSTS
cat > "$ROOTFS/usr/lib/os-release" <<OSREL
NAME="BOLT OS"
PRETTY_NAME="BOLT OS $BOLT_VERSION"
ID=bolt
VERSION="$BOLT_VERSION"
VERSION_ID="$BOLT_VERSION"
ANSI_COLOR="0;33"
HOME_URL="https://github.com/BoltGamingOfficial/bolt-os"
SUPPORT_URL="https://github.com/BoltGamingOfficial/bolt-os/issues"
BUG_REPORT_URL="https://github.com/BoltGamingOfficial/bolt-os/issues"
OSREL
ln -sfn ../usr/lib/os-release "$ROOTFS/etc/os-release"

if [[ -f "$ROOTFS/etc/locale.gen" ]]; then
  sed -i 's/^#en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' "$ROOTFS/etc/locale.gen"
fi
printf 'LANG=en_US.UTF-8\n' > "$ROOTFS/etc/locale.conf"
arch-chroot "$ROOTFS" locale-gen
arch-chroot "$ROOTFS" passwd -l root
arch-chroot "$ROOTFS" visudo -cf /etc/sudoers

log 'Enabling only the desktop, network, power-profile, and first-run services.'
systemctl --root="$ROOTFS" enable dbus.socket
systemctl --root="$ROOTFS" enable NetworkManager.service
systemctl --root="$ROOTFS" enable power-profiles-daemon.service
systemctl --root="$ROOTFS" enable sddm.service
systemctl --root="$ROOTFS" enable bolt-first-run.service
systemctl --root="$ROOTFS" set-default graphical.target
install -d "$ROOTFS/etc/systemd/user/sockets.target.wants" "$ROOTFS/etc/systemd/user/default.target.wants"
for unit in pipewire.socket pipewire-pulse.socket; do
  [[ -s "$ROOTFS/usr/lib/systemd/user/$unit" ]] || fail "missing user audio socket: $unit"
  ln -sfn "/usr/lib/systemd/user/$unit" "$ROOTFS/etc/systemd/user/sockets.target.wants/$unit"
done
[[ -s "$ROOTFS/usr/lib/systemd/user/wireplumber.service" ]] || fail 'missing WirePlumber user service'
ln -sfn /usr/lib/systemd/user/wireplumber.service \
  "$ROOTFS/etc/systemd/user/default.target.wants/wireplumber.service"

KERNEL_VERSION="$(find "$ROOTFS/usr/lib/modules" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' | LC_ALL=C sort | tail -n 1)"
[[ -n "$KERNEL_VERSION" ]] || fail 'the kernel package did not install a modules directory'
[[ -s "$ROOTFS/boot/vmlinuz-linux" ]] || fail 'the kernel image /boot/vmlinuz-linux is missing'
[[ -s "$ROOTFS/boot/intel-ucode.img" ]] || fail 'the Intel microcode image is missing'
[[ -s "$ROOTFS/boot/amd-ucode.img" ]] || fail 'the AMD microcode image is missing'

log "Generating the BOLT initramfs for kernel $KERNEL_VERSION."
arch-chroot "$ROOTFS" mkinitcpio -k "$KERNEL_VERSION" -c /etc/mkinitcpio.conf -g /boot/initramfs-bolt.img
[[ -s "$ROOTFS/boot/initramfs-bolt.img" ]] || fail 'mkinitcpio did not produce an initramfs image'

log 'Removing documentation, package caches, and unused locales.'
rm -rf "$ROOTFS/usr/share/man" "$ROOTFS/usr/share/doc" "$ROOTFS/usr/share/info" "$ROOTFS/usr/share/gtk-doc" "$ROOTFS/var/cache/pacman/pkg"/*
if [[ -d "$ROOTFS/usr/share/locale" ]]; then
  find "$ROOTFS/usr/share/locale" -mindepth 1 -maxdepth 1 -type d \
    ! -name en_US ! -name C ! -name C.utf8 -exec rm -rf -- {} +
fi
rm -f "$ROOTFS/var/log/pacman.log" "$ROOTFS/var/log/lastlog"

log 'Measuring and creating the compressed system image.'
ROOTFS_BYTES="$(du -s --bytes "$ROOTFS" | awk '{print $1}')"
printf 'BOLT root filesystem (uncompressed): %s bytes\n' "$ROOTFS_BYTES"
mksquashfs "$ROOTFS" "$ISO_ROOT/BOLT/system.squashfs" -comp zstd -Xcompression-level 15 -b 1M -noappend -processors "$(getconf _NPROCESSORS_ONLN)" -no-progress

log 'Staging the independent Limine boot tree.'
install -m 0644 "$ROOTFS/boot/vmlinuz-linux" "$ISO_ROOT/BOLT/boot/vmlinuz"
install -m 0644 "$ROOTFS/boot/intel-ucode.img" "$ISO_ROOT/BOLT/boot/intel-ucode.img"
install -m 0644 "$ROOTFS/boot/amd-ucode.img" "$ISO_ROOT/BOLT/boot/amd-ucode.img"
install -m 0644 "$ROOTFS/boot/initramfs-bolt.img" "$ISO_ROOT/BOLT/boot/initramfs-bolt.img"
install -m 0644 "$ROOT_DIR/limine.conf" "$ISO_ROOT/boot/limine/limine.conf"
for boot_file in limine-bios-cd.bin limine-uefi-cd.bin limine-bios.sys BOOTX64.EFI; do
  [[ -s "/usr/share/limine/$boot_file" ]] || fail "Limine package file is missing: /usr/share/limine/$boot_file"
done
install -m 0644 /usr/share/limine/limine-bios-cd.bin "$ISO_ROOT/boot/limine/limine-bios-cd.bin"
install -m 0644 /usr/share/limine/limine-uefi-cd.bin "$ISO_ROOT/boot/limine/limine-uefi-cd.bin"
install -m 0644 /usr/share/limine/limine-bios.sys "$ISO_ROOT/boot/limine/limine-bios.sys"
install -m 0644 /usr/share/limine/BOOTX64.EFI "$ISO_ROOT/EFI/BOOT/BOOTX64.EFI"

cat > "$ISO_ROOT/BOLT/build-info.txt" <<INFO
Distribution: BOLT OS
Version: $BOLT_VERSION
Architecture: x86_64
Boot manager: Limine (UEFI + legacy BIOS hybrid ISO)
Kernel: $KERNEL_VERSION
Package source: official Arch repositories (core/extra/multilib)
Boot layout: /BOLT/boot plus /BOLT/system.squashfs
Writable live overlay: tmpfs capped at 50% of detected physical RAM; not disk storage
INFO

log 'Creating the UEFI/BIOS hybrid ISO with the BOLT_LIVE volume label.'
xorriso -as mkisofs -R -r -J -V BOLT_LIVE \
  -b boot/limine/limine-bios-cd.bin -no-emul-boot -boot-load-size 4 -boot-info-table \
  -hfsplus -apm-block-size 2048 \
  --efi-boot boot/limine/limine-uefi-cd.bin -efi-boot-part -efi-boot-image \
  --protective-msdos-label "$ISO_ROOT" -o "$ISO_PATH"
limine bios-install "$ISO_PATH"

log 'Verifying ISO structure, boot catalog, and checksum.'
xorriso -indev "$ISO_PATH" -report_el_torito plain > "$DELIVERY_DIR/testing/el-torito-report.txt" 2>&1
xorriso -indev "$ISO_PATH" -find / -name system.squashfs -print > "$DELIVERY_DIR/testing/iso-files.txt" 2>&1
grep -q '/BOLT/system.squashfs' "$DELIVERY_DIR/testing/iso-files.txt" || fail 'system squashfs is not present in the ISO'
grep -Eiq '0xef|EFI' "$DELIVERY_DIR/testing/el-torito-report.txt" || fail 'ISO does not report an EFI boot catalog entry'
(cd "$DELIVERY_DIR/iso" && sha256sum "$ISO_NAME") > "$DELIVERY_DIR/checksums/$ISO_NAME.sha256"
(cd "$DELIVERY_DIR/iso" && sha256sum -c "../checksums/$ISO_NAME.sha256")

ISO_BYTES="$(stat -c '%s' "$ISO_PATH")"
SQUASHFS_BYTES="$(stat -c '%s' "$ISO_ROOT/BOLT/system.squashfs")"
cat > "$DELIVERY_DIR/testing/build-measurements.txt" <<MEASURE
Build version: $BOLT_VERSION
Architecture: x86_64
Kernel version: $KERNEL_VERSION
Uncompressed live rootfs bytes: $ROOTFS_BYTES
Compressed squashfs bytes: $SQUASHFS_BYTES
ISO bytes: $ISO_BYTES
ISO SHA-256: $(cut -d ' ' -f 1 "$DELIVERY_DIR/checksums/$ISO_NAME.sha256")
Idle RAM: NOT MEASURED (requires booted VM or physical hardware)
Installed disk footprint: NOT MEASURED (no disk installer is shipped)
MEASURE

log 'Build completed; the ISO has not been boot-tested by this script.'
printf 'ISO: %s\nSize: %s bytes\nSHA-256 file: %s\n' "$ISO_PATH" "$ISO_BYTES" "$DELIVERY_DIR/checksums/$ISO_NAME.sha256"
