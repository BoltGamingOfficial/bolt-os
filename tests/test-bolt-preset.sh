#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT
export HOME="$TMP_DIR/home"
export XDG_CONFIG_HOME="$HOME/.config"
mkdir -p "$HOME"
SCRIPT="$ROOT_DIR/rootfs-overlay/usr/local/bin/bolt-preset"

bash "$SCRIPT" gaming >/dev/null
[[ "$(cat "$XDG_CONFIG_HOME/bolt-os/preset.conf")" == gaming ]]
[[ "$(bash "$SCRIPT" status)" == *'Saved BOLT preset: gaming'* ]]
bash "$SCRIPT" battery >/dev/null
[[ "$(cat "$XDG_CONFIG_HOME/bolt-os/preset.conf")" == battery ]]
bash "$SCRIPT" reset >/dev/null
[[ ! -e "$XDG_CONFIG_HOME/bolt-os/preset.conf" ]]
[[ "$(bash "$SCRIPT" status)" == *'Saved BOLT preset: balanced'* ]]
printf 'PASS: BOLT power preset persistence and reset\n'
