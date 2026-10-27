# Memory Budget and Performance Tests

## Goal

BOLT OS must not burn RAM on features the user did not ask for. Gaming tools can be installed without running in the background: Steam, Lutris, GameMode, Gamescope, and MangoHud must not launch automatically at login.

The first target is a **lean idle desktop**, not a benchmark claim. Until the ISO has been built and measured, no RAM number is a verified result.

## Runtime rules

- No AI/chat assistant starts with the desktop. OpenCode remains optional and user-launched.
- No Steam, Lutris, or other game launcher autostarts by default.
- Disable KDE Baloo file indexing by default in the live prototype; offer the choice to enable it later.
- Enable only services needed for networking and the graphical login by default. Bluetooth packages remain installed, but the Bluetooth daemon is not enabled at boot unless explicitly requested when building the ISO (`BOLT_ENABLE_BLUETOOTH=1`). This avoids starting an unused service while retaining a documented opt-in.
- Do not trade away essential security, audio, networking, power management, or accessibility just to reduce a screenshot's memory number.
- Do not confuse disk usage from installed applications with RAM consumed by running processes.

## Initial measurement target

Aim for no more than **1.5 GiB of process memory attributable to the idle desktop and enabled services** on a defined 8 GiB x86-64 reference system after login, with no apps open and after a three-minute settling period. This is a goal to test, not a measured achievement or guarantee. The exact metric and test fixture must be recorded before judging pass/fail.

## How to interpret the numbers

Linux deliberately uses otherwise-free RAM for filesystem cache and reclaims it when applications need memory. A single “used RAM” number can therefore be misleading. Track `MemAvailable`, swap pressure, and process PSS alongside RSS; do not call reclaimable cache a leak.

## Test procedure

Run after a clean boot and again after updates:

```sh
uname -a
systemd-analyze time
systemd-analyze blame
free -h
cat /proc/meminfo | grep -E 'MemTotal|MemAvailable|SwapTotal|SwapFree'
systemctl --type=service --state=running
ps -eo pid,comm,rss --sort=-rss | head -n 20
```

Record:
- RAM capacity and GPU model
- kernel and package snapshot/date
- display session (Wayland or X11)
- idle memory and MemAvailable after three minutes
- running services and top RSS processes
- whether firmware, Wi-Fi, Bluetooth, or desktop indexing changed the result

Repeat with a 4 GiB test system and on at least one real PC. A VM-only result is useful but does not replace hardware testing. Use PSS or proportional memory measurements for serious comparisons; RSS can double-count shared pages.

## Release criteria

- Publish the test setup and raw output.
- Compare on the same hardware against a clearly defined upstream KDE baseline.
- Measure cold boot, idle memory, and gaming frame times separately.
- Investigate regressions instead of hiding them by changing the reported metric.
