#!/usr/bin/env bash
set -Eeuo pipefail
OUT_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/bolt-os"
mkdir -p "$OUT_DIR"
REPORT="$OUT_DIR/vm-smoke-$(date +%Y%m%d-%H%M%S).txt"
exec > >(tee "$REPORT") 2>&1
failures=0
check() {
  local label="$1"; shift
  if "$@"; then printf 'PASS: %s\n' "$label"; else printf 'FAIL: %s\n' "$label"; failures=$((failures + 1)); fi
}

printf 'BOLT OS runtime smoke test\nDate: %s\nKernel: %s\nSession: %s\n' \
  "$(date -Is)" "$(uname -r)" "${XDG_SESSION_TYPE:-unknown}"
printf '\nMemory snapshot (wait 180 seconds after desktop settles):\n'
free -h
awk '/^(MemTotal|MemAvailable|SwapTotal|SwapFree):/ {print}' /proc/meminfo
printf '\nBoot timing and failed units:\n'
systemd-analyze time || true
systemd-analyze --failed --no-pager || true
printf '\nLargest resident processes:\n'
ps -eo pid,comm,%cpu,rss --sort=-rss | head -n 15
printf '\nFilesystem usage:\n'
df -h / /run

check 'first-run setup is complete' test -s /var/lib/bolt/first-run-complete
check 'NetworkManager is active' systemctl is-active --quiet NetworkManager
check 'power-profiles-daemon is active' systemctl is-active --quiet power-profiles-daemon
check 'SDDM is active' systemctl is-active --quiet sddm
check 'Steam executable exists' command -v steam
check 'Lutris executable exists' command -v lutris
check 'Gamescope executable exists' command -v gamescope
check 'MangoHud command exists' command -v mangohud
check 'BOLT wallpaper exists' test -s /usr/share/wallpapers/BOLT.svg
check 'BOLT OS identity exists' grep -q '^ID=bolt$' /etc/os-release
root_locked() { [[ "$(passwd -S root | awk '{print $2}')" == L ]]; }
check 'root account is locked' root_locked
sudo_requires_authentication() { ! grep -Rqs 'NOPASSWD' /etc/sudoers /etc/sudoers.d; }
check 'sudo requires authentication' sudo_requires_authentication

printf '\nGraphics and Vulkan:\n'
if command -v vulkaninfo >/dev/null 2>&1; then vulkaninfo --summary 2>&1 || true; else printf 'vulkaninfo missing\n'; fi
if command -v glxinfo >/dev/null 2>&1; then glxinfo -B 2>&1 || true; fi
printf '\nReport saved: %s\n' "$REPORT"
if (( failures > 0 )); then printf 'RESULT: FAIL (%d required checks failed)\n' "$failures"; exit 1; fi
printf 'RESULT: required checks passed; hardware-specific GPU and gameplay tests still require manual validation.\n'
