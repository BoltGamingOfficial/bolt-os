#!/usr/bin/env bash
set -Eeuo pipefail
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
SCRIPT="$ROOT_DIR/rootfs-overlay/usr/local/libexec/bolt-first-run"
export BOLT_FIRST_RUN_TEST_ONLY=1
# shellcheck disable=SC1090
source "$SCRIPT"

for good in bolt gamer _gamer user-1; do
  bolt_valid_username "$good" || { printf 'FAIL: rejected valid username %s\n' "$good" >&2; exit 1; }
done
for bad in '' Root 'two words' 'a.b' root daemon; do
  if bolt_valid_username "$bad"; then printf 'FAIL: accepted invalid username %s\n' "$bad" >&2; exit 1; fi
done
bolt_passwords_valid 'correct-horse-battery-staple' 'correct-horse-battery-staple' || { echo 'FAIL: valid password rejected' >&2; exit 1; }
if bolt_passwords_valid 'short' 'short'; then echo 'FAIL: short password accepted' >&2; exit 1; fi
if bolt_passwords_valid 'correct-horse-battery-staple' 'different-password-value'; then echo 'FAIL: mismatched passwords accepted' >&2; exit 1; fi
bolt_valid_timezone Etc/UTC || { echo 'FAIL: Etc/UTC timezone rejected' >&2; exit 1; }
if bolt_valid_timezone '../../../etc/passwd'; then echo 'FAIL: path traversal timezone accepted' >&2; exit 1; fi

if [[ -r /usr/share/X11/xkb/rules/base.lst ]]; then
  bolt_valid_layout us || { echo 'FAIL: valid XKB us layout rejected' >&2; exit 1; }
  if bolt_valid_layout notareallayout; then echo 'FAIL: invalid XKB layout accepted' >&2; exit 1; fi
else
  printf 'BLOCKED: XKB layout unit check; xkeyboard-config data absent on test host\n'
fi

password='BOLT-test-only-password-928!'
hash="$(bolt_hash_password "$password")"
hash_again="$(bolt_hash_password "$password")"
[[ "$hash" != "$hash_again" ]] || { echo 'FAIL: hash salt is not random' >&2; exit 1; }
[[ "$hash" == '$6$'* ]] || { echo 'FAIL: SHA-512 crypt hash prefix absent' >&2; exit 1; }
[[ "$hash" != "$password" ]] || { echo 'FAIL: password was not hashed' >&2; exit 1; }
unset password hash hash_again
printf 'PASS: first-run validators and salted SHA-512 password hashing\n'
