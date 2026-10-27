#!/usr/bin/env bash
set -Eeuo pipefail
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
export HOME="$tmp/home"
export XDG_CONFIG_HOME="$HOME/.config"
mkdir -p "$HOME"
script="${1:-./airootfs/usr/local/bin/bolt-preset}"

bash "$script" gaming >/dev/null
[[ "$(cat "$XDG_CONFIG_HOME/bolt-os/preset.conf")" == gaming ]]
[[ "$(bash "$script" status)" == *"Saved BOLT preset: gaming"* ]]
bash "$script" battery >/dev/null
[[ "$(cat "$XDG_CONFIG_HOME/bolt-os/preset.conf")" == battery ]]
bash "$script" reset >/dev/null
[[ ! -e "$XDG_CONFIG_HOME/bolt-os/preset.conf" ]]
[[ "$(bash "$script" status)" == *"Saved BOLT preset: balanced"* ]]
echo "BOLT preset persistence tests passed."
