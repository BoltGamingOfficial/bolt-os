#!/usr/bin/env bash
set -Eeuo pipefail
ISO_PATH="${1:-}"
TIMEOUT_SECONDS="${QEMU_BOOT_TIMEOUT:-150}"
fail() { printf 'FAIL: %s\n' "$*" >&2; exit 1; }

[[ -n "$ISO_PATH" && -s "$ISO_PATH" ]] || fail 'usage: qemu-uefi-smoke.sh /path/to/BOLT-OS.iso'
command -v qemu-system-x86_64 >/dev/null 2>&1 || { echo 'BLOCKED: qemu-system-x86_64 is not installed'; exit 77; }
command -v timeout >/dev/null 2>&1 || fail 'timeout command is required'
OVMF_CODE="$(find /usr/share -type f \( -name 'OVMF_CODE.4m.fd' -o -name 'OVMF_CODE.fd' \) -print -quit 2>/dev/null || true)"
[[ -n "$OVMF_CODE" && -s "$OVMF_CODE" ]] || { echo 'BLOCKED: OVMF_CODE firmware was not found under /usr/share'; exit 77; }
OVMF_VARS="$(dirname "$OVMF_CODE")/$(basename "$OVMF_CODE" | sed 's/OVMF_CODE/OVMF_VARS/')"
[[ -s "$OVMF_VARS" ]] || { echo "BLOCKED: matching OVMF_VARS file not found for $OVMF_CODE"; exit 77; }

TMP_DIR="$(mktemp -d)"
trap 'rm -rf -- "$TMP_DIR"' EXIT
cp "$OVMF_VARS" "$TMP_DIR/OVMF_VARS.fd"
SERIAL_LOG="$TMP_DIR/serial.log"
REPORT_DIR="${QEMU_REPORT_DIR:-}"
if [[ -r /dev/kvm && -w /dev/kvm ]]; then
  ACCEL=( -accel kvm -cpu host )
else
  ACCEL=( -accel tcg -cpu max )
fi

printf 'Starting UEFI QEMU boot probe for %s\n' "$ISO_PATH"
set +e
timeout --foreground "$TIMEOUT_SECONDS" qemu-system-x86_64 \
  -machine q35 "${ACCEL[@]}" -m 2048 -smp 2 \
  -drive "if=pflash,format=raw,readonly=on,file=$OVMF_CODE" \
  -drive "if=pflash,format=raw,file=$TMP_DIR/OVMF_VARS.fd" \
  -cdrom "$ISO_PATH" -boot order=d -display none \
  -serial "file:$SERIAL_LOG" -monitor none -net none -no-reboot -no-shutdown
QEMU_STATUS=$?
set -e

if (( QEMU_STATUS != 124 && QEMU_STATUS != 0 )); then
  cat "$SERIAL_LOG" 2>/dev/null || true
  fail "QEMU exited unexpectedly with status $QEMU_STATUS"
fi
[[ -s "$SERIAL_LOG" ]] || fail 'no serial output captured from the booted guest'
if [[ -n "$REPORT_DIR" ]]; then
  install -d "$REPORT_DIR"
  install -m 0644 "$SERIAL_LOG" "$REPORT_DIR/qemu-uefi-serial.log"
fi
grep -Fq 'BOLT: live overlay upper limit' "$SERIAL_LOG" || {
  cat "$SERIAL_LOG"
  fail 'the BOLT initramfs did not report a mounted writable overlay'
}
grep -Fq 'systemd[1]' "$SERIAL_LOG" || {
  cat "$SERIAL_LOG"
  fail 'systemd did not start after the BOLT root switch'
}
printf 'PASS: UEFI firmware, Limine boot, custom BOLT initramfs, squashfs mount, RAM overlay, and systemd handoff\n'
printf 'NOTE: first-run interaction, SDDM, Plasma, audio, and GPU acceleration need a graphical VM/hardware test.\n'
