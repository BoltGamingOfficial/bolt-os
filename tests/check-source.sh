#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

[[ -s "$ROOT_DIR/build.sh" ]] || fail 'build.sh missing'
[[ -s "$ROOT_DIR/packages.x86_64" ]] || fail 'package manifest missing'
[[ -s "$ROOT_DIR/limine.conf" ]] || fail 'Limine configuration missing'
[[ -s "$ROOT_DIR/branding/bolt-boot.png" ]] || fail 'Limine wallpaper image missing'
[[ -s "$ROOT_DIR/mkinitcpio/hooks/bolt_live" ]] || fail 'BOLT live initramfs hook missing'
[[ -s "$ROOT_DIR/mkinitcpio/install/bolt_live" ]] || fail 'BOLT live initramfs installer hook missing'
[[ -s "$ROOT_DIR/rootfs-overlay/usr/local/libexec/bolt-first-run" ]] || fail 'first-run program missing'
[[ -x "$ROOT_DIR/rootfs-overlay/usr/local/libexec/bolt-first-run" ]] || fail 'first-run program must be executable'
[[ -x "$ROOT_DIR/rootfs-overlay/usr/local/bin/apt" ]] || fail 'apt helper must be executable'
[[ -x "$ROOT_DIR/rootfs-overlay/usr/local/bin/bolt-help" ]] || fail 'BOLT help command must be executable'
[[ -s "$ROOT_DIR/rootfs-overlay/etc/profile.d/00-bolt-path.sh" ]] || fail 'login PATH profile is missing'
[[ -s "$ROOT_DIR/rootfs-overlay/etc/systemd/zram-generator.conf" ]] || fail 'zram config is missing'
[[ -s "$ROOT_DIR/rootfs-overlay/etc/skel/.config/kdeglobals" ]] || fail 'KDE defaults are missing'
[[ -s "$ROOT_DIR/rootfs-overlay/usr/local/bin/bolt-install-roblox" ]] || fail 'Roblox installer launcher missing'
[[ -x "$ROOT_DIR/rootfs-overlay/usr/local/bin/bolt-install-roblox" ]] || fail 'Roblox installer launcher must be executable'
[[ -s "$ROOT_DIR/rootfs-overlay/usr/share/applications/bolt-roblox.desktop" ]] || fail 'Roblox menu entry missing'
[[ -s "$ROOT_DIR/rootfs-overlay/etc/skel/.config/mimeapps.list" ]] || fail 'default file associations missing'
[[ -s "$ROOT_DIR/rootfs-overlay/etc/environment" ]] || fail 'system environment file missing'
grep -Fxq 'PATH=/usr/local/sbin:/usr/local/bin:/usr/bin' "$ROOT_DIR/rootfs-overlay/etc/environment" || fail 'system PATH must include /usr/bin'
grep -Fq '/usr/bin' "$ROOT_DIR/rootfs-overlay/etc/profile.d/00-bolt-path.sh" || fail 'login profile must include /usr/bin'
grep -Fq 'pacman -Syu' "$ROOT_DIR/rootfs-overlay/usr/local/bin/apt" || fail 'apt helper must map updates to full Arch upgrade'
grep -Fq 'AnimationDurationFactor=0.5' "$ROOT_DIR/rootfs-overlay/etc/skel/.config/kdeglobals" || fail 'KDE animation defaults missing'
grep -Fq 'zram-size = min(ram / 2, 4096)' "$ROOT_DIR/rootfs-overlay/etc/systemd/zram-generator.conf" || fail 'zram policy missing'

mapfile -t scripts < <(find "$ROOT_DIR" -type f \( -name '*.sh' -o -path '*/usr/local/bin/bolt-preset' -o -path '*/usr/local/bin/bolt-install-roblox' -o -path '*/usr/local/bin/apt' -o -path '*/usr/local/bin/bolt-help' -o -path '*/usr/local/libexec/bolt-first-run' -o -path '*/usr/local/libexec/bolt-set-wallpaper-once' -o -path '*/mkinitcpio/hooks/bolt_live' -o -path '*/mkinitcpio/install/bolt_live' \) -print | sort)
for script in "${scripts[@]}"; do bash -n "$script" || fail "shell syntax: $script"; done

packages="$ROOT_DIR/packages.x86_64"
duplicates="$(grep -Ev '^[[:space:]]*(#|$)' "$packages" | LC_ALL=C sort | uniq -d)"
[[ -z "$duplicates" ]] || fail "duplicate packages: $duplicates"
for package in base mkinitcpio linux linux-firmware networkmanager wpa_supplicant dbus-broker-units kbd xkeyboard-config plasma-desktop sddm xorg-server sudo firefox prismlauncher jre21-openjdk bash-completion zram-generator wine wine-gecko wine-mono winetricks flatpak steam lutris gamemode gamescope mangohud mesa lib32-mesa vulkan-intel vulkan-radeon lib32-vulkan-intel lib32-vulkan-radeon nvidia-open nvidia-utils lib32-nvidia-utils kate gwenview vlc vlc-plugins-extra kimageformats qt6-imageformats ffmpegthumbs jq mesa-utils xdg-desktop-portal-gtk; do
  grep -Fxq "$package" "$packages" || fail "required package missing: $package"
done
for forbidden in bluez archiso mkarchiso opencode ollama; do
  if grep -Fxq "$forbidden" "$packages"; then fail "unexpected package in minimal manifest: $forbidden"; fi
done

if grep -RniE 'NOPASSWD|\[Autologin\]|^[[:space:]]*User=bolt([[:space:]]|$)' \
  "$ROOT_DIR/rootfs-overlay"; then
  fail 'passwordless sudo or fixed-user autologin configuration found'
fi
grep -Fq '%wheel ALL=(ALL:ALL) ALL' "$ROOT_DIR/rootfs-overlay/etc/sudoers.d/10-bolt-wheel" || fail 'wheel sudo policy missing'
grep -Fq 'passwd -l root' "$ROOT_DIR/build.sh" || fail 'root account is not locked at image build time'
grep -Fq 'chpasswd --encrypted' "$ROOT_DIR/rootfs-overlay/usr/local/libexec/bolt-first-run" || fail 'password hash is not installed through encrypted chpasswd'
grep -Fq 'gamemode' "$ROOT_DIR/rootfs-overlay/usr/local/libexec/bolt-first-run" || fail 'GameMode group is not included when available'
grep -Fq 'openssl passwd -6 -stdin' "$ROOT_DIR/rootfs-overlay/usr/local/libexec/bolt-first-run" || fail 'password hashing command missing'
grep -Fq 'Requires=bolt-first-run.service' "$ROOT_DIR/rootfs-overlay/etc/systemd/system/sddm.service.d/10-bolt-first-run.conf" || fail 'SDDM is not gated by first-run setup'
grep -Fq 'Conflicts=getty@tty1.service' "$ROOT_DIR/rootfs-overlay/etc/systemd/system/bolt-first-run.service" || fail 'first-run wizard may race with the tty1 getty'
grep -Fq 'first-run-complete' "$ROOT_DIR/rootfs-overlay/usr/local/libexec/bolt-first-run" || fail 'first-run completion marker handling missing'
grep -Fq 'interface_branding: BOLT OS' "$ROOT_DIR/limine.conf" || fail 'Limine branding missing'
grep -Fq 'wallpaper: boot():/BOLT/bolt-boot.png' "$ROOT_DIR/limine.conf" || fail 'Limine wallpaper path missing'
grep -Fq 'bolt-boot.png' "$ROOT_DIR/build.sh" || fail 'Limine wallpaper is not staged into the ISO'
grep -Fq 'BOOTX64.EFI' "$ROOT_DIR/build.sh" || fail 'UEFI fallback loader is not staged into the ISO'
grep -Fq -- '-efi-boot-part --efi-boot-image --protective-msdos-label' "$ROOT_DIR/build.sh" || fail 'UEFI hybrid GPT partition is missing'
# shellcheck disable=SC2016 # Match the literal command as it appears in build.sh.
grep -Fq 'xorriso -indev "$ISO_PATH" -find / -name system.squashfs' "$ROOT_DIR/build.sh" || fail 'ISO verification must use xorriso find with its default echo action'
if grep -Fq -- '-name system.squashfs -print' "$ROOT_DIR/build.sh"; then
  fail 'xorriso -find must not use GNU find -print syntax'
fi
grep -Fq 'BOLT_LIVE' "$ROOT_DIR/mkinitcpio/hooks/bolt_live" || fail 'custom boot medium label missing'
grep -Fq 'MemTotal:' "$ROOT_DIR/mkinitcpio/hooks/bolt_live" || fail 'memory-aware overlay sizing missing'
grep -Fq 'newroot=/newroot' "$ROOT_DIR/mkinitcpio/hooks/bolt_live" || fail 'new root must not be nested inside /run before moving /run'
grep -Fq 'timeout: 2' "$ROOT_DIR/limine.conf" || fail 'Limine should use a short boot menu countdown'
grep -Fq 'COMPRESSION_OPTIONS=(-3)' "$ROOT_DIR/mkinitcpio/bolt-live.conf" || fail 'initramfs should use fast zstd compression'
if grep -Eq '^MODULES=.*nvidia' "$ROOT_DIR/mkinitcpio/bolt-live.conf"; then fail 'NVIDIA modules must not be forced into every initramfs'; fi
grep -Fq 'org.vinegarhq.Sober' "$ROOT_DIR/rootfs-overlay/usr/local/bin/bolt-install-roblox" || fail 'Roblox launcher must target Sober'
grep -Fq -- '--diagnose' "$ROOT_DIR/rootfs-overlay/usr/local/bin/bolt-install-roblox" || fail 'Roblox launcher diagnostics missing'
grep -Fq 'use_opengl = true' "$ROOT_DIR/rootfs-overlay/usr/local/bin/bolt-install-roblox" || fail 'Sober OpenGL workaround missing'
grep -Fq 'render' "$ROOT_DIR/rootfs-overlay/usr/local/libexec/bolt-first-run" || fail 'render GPU access group missing'
grep -Fq 'org.kde.kate.desktop' "$ROOT_DIR/rootfs-overlay/etc/skel/.config/mimeapps.list" || fail 'Kate text default missing'
grep -Fq 'vlc.desktop' "$ROOT_DIR/rootfs-overlay/etc/skel/.config/mimeapps.list" || fail 'VLC audio/video defaults missing'
grep -Fq 'org.kde.gwenview.desktop' "$ROOT_DIR/rootfs-overlay/etc/skel/.config/mimeapps.list" || fail 'Gwenview image defaults missing'
grep -Fq 'https://dl.flathub.org/repo/flathub.flatpakrepo' "$ROOT_DIR/rootfs-overlay/usr/local/bin/bolt-install-roblox" || fail 'Roblox launcher must use Flathub'
grep -Fq 'unofficial' "$ROOT_DIR/rootfs-overlay/usr/local/bin/bolt-install-roblox" || fail 'Roblox launcher must disclose unofficial status'
if grep -Fq 'newroot=/run/' "$ROOT_DIR/mkinitcpio/hooks/bolt_live"; then fail 'new root is nested under /run'; fi

if grep -RniE 'archiso|mkarchiso|install_dir="arch"|AI Hub|OpenCode' \
  "$ROOT_DIR" --exclude='check-source.sh'; then
  fail 'legacy image framework or AI feature references remain in delivery source'
fi

printf 'PASS: source structure, Bash syntax, package manifest, UEFI boot, first-run gate, terminal compatibility and memory defaults\n'
