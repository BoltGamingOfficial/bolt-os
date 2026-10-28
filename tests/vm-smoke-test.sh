#!/usr/bin/env bash
set -Eeuo pipefail

# Run inside a booted BOLT OS live session as the desktop user.
# This is a diagnostic smoke test, not a substitute for manual interaction tests.
ROOT_OUT="${XDG_STATE_HOME:-$HOME/.local/state}/bolt-os"
mkdir -p "$ROOT_OUT"
REPORT="$ROOT_OUT/vm-smoke-$(date +%Y%m%d-%H%M%S).txt"
exec > >(tee "$REPORT") 2>&1

failures=0
check() {
  local label="$1"
  shift
  if "$@"; then
    printf 'PASS: %s\n' "$label"
  else
    printf 'FAIL: %s\n' "$label"
    failures=$((failures + 1))
  fi
}

printf 'BOLT OS VM smoke test\nDate: %s\nHost: %s\nKernel: %s\n' \
  "$(date -Is)" "$(hostname)" "$(uname -r)"
printf 'Session: %s\\nDesktop: %s\\n' "${XDG_SESSION_TYPE:-unknown}" "${XDG_CURRENT_DESKTOP:-unknown}"
printf 'CPU / virtualization snapshot:\\n'
lscpu 2>/dev/null | grep -E '^(Architecture|CPU\\(s\\)|Model name|Hypervisor vendor|Virtualization type):' || true
printf '\\nMemory snapshot (wait three minutes after login for comparable measurements):\\n'
free -h
grep -E 'MemTotal|MemAvailable|SwapTotal|SwapFree' /proc/meminfo || true
printf '\\nBoot and failed-unit snapshot:\\n'
systemd-analyze time || true
systemd-analyze blame --no-pager 2>/dev/null | head -n 15 || true
systemd-analyze --failed --no-pager || true
printf '\\nVirtualBox guest integration:\\n'
systemctl --no-pager status vboxservice.service 2>&1 || true
pgrep -af 'VBoxClient|kwin_wayland|kwin_x11|plasmashell' || true
printf '\\nGraphics renderer (if glxinfo is available):\\n'
if command -v glxinfo >/dev/null 2>&1; then
  glxinfo -B 2>&1 || true
else
  printf 'glxinfo is not installed; renderer could not be queried by this script.\\n'
fi

check "Firefox executable is installed" command -v firefox
check "Steam executable is installed" command -v steam
check "BOLT wallpaper asset exists" test -s /usr/share/wallpapers/BOLT.svg
check "NetworkManager service is active" systemctl is-active --quiet NetworkManager
check "display manager service is active" systemctl is-active --quiet display-manager

printf '\nRelevant service state:\n'
systemctl --no-pager --full status NetworkManager display-manager 2>&1 || true
printf '\nGraphics/Vulkan tools:\n'
if command -v vulkaninfo >/dev/null 2>&1; then
  vulkaninfo --summary 2>&1 || true
else
  printf 'vulkaninfo is unavailable\n'
fi
printf '\nLargest resident processes:\n'
ps -eo pid,comm,%cpu,rss --sort=-rss | head -n 15
printf '\nDisk usage:\n'
df -h / /home

# Persistence probe: first run creates a sentinel; a later run checks whether
# it survived a reboot. On the current ephemeral live ISO it is expected to
# disappear after a full reboot/shutdown; installed-system persistence is a
# separate release gate and cannot be proven by an ISO build.
probe="$HOME/.config/bolt-os/persistence-probe"
if [[ -e "$probe" ]]; then
  printf 'PERSISTENCE: sentinel exists from an earlier run: '
  cat "$probe"
  printf 'PERSISTENCE: if this is a fresh boot, user config survived reboot.\n'
else
  install -d "$HOME/.config/bolt-os"
  printf 'created=%s\n' "$(date -Is)" > "$probe"
  printf 'PERSISTENCE: created sentinel at %s. Reboot or fully shut down, then rerun this script.\n' "$probe"
fi

printf '\nReport saved to: %s\n' "$REPORT"
if (( failures > 0 )); then
  printf 'RESULT: FAIL (%d required checks failed)\n' "$failures"
  exit 1
fi
printf 'RESULT: required smoke checks passed; manual interaction and persistence checks remain necessary.\n'
