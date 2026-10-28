# Memory Budget and Performance Tests

## Goals

BOLT OS should remain responsive on modest hardware. Use these separate targets rather than treating one number as proof that the system is lightweight:

- **Minimum-memory target: 2 GiB RAM.** The live desktop should boot and support basic desktop tasks without persistent swapping or severe UI stalls. This is a compatibility target to validate, not a claim that every game or browser workload fits in 2 GiB.
- **Idle target: at most 1.5 GiB** attributable to the idle desktop and enabled services on the defined 8 GiB x86-64 reference system, after login and a three-minute settling period. This remains a goal until measured.
- **Gaming target:** measure the game, graphics driver, desktop, and launcher together. Requirements vary by game; never promise that modern games run within 2 GiB.

Steam, Lutris, Prism Launcher, GameMode, Gamescope, and MangoHud can be installed without running in the background. Do not remove applications just because they occupy disk space; focus on processes and services that actually consume runtime resources.

## Runtime rules

- No AI/chat assistant starts with the desktop. OpenCode remains optional and user-launched.
- No Steam, Lutris, Prism Launcher, or other game launcher autostarts by default.
- Disable KDE Baloo file indexing by default in the live prototype; offer the choice to enable it later.
- Enable only services needed for networking and the graphical login by default. Bluetooth packages remain installed, but the Bluetooth daemon is not enabled at boot unless explicitly requested when building the ISO (`BOLT_ENABLE_BLUETOOTH=1`).
- Do not trade away essential security, audio, networking, power management, or accessibility just to reduce a screenshot's memory number.
- Do not confuse disk usage from installed applications with RAM consumed by running processes.
- Diagnose VM rendering and host resource contention before changing KDE effects or removing packages.

## How to interpret memory

Linux deliberately uses otherwise-free RAM for filesystem cache and reclaims it when applications need it. A single “used RAM” number can therefore be misleading. Track `MemAvailable`, swap pressure, and process PSS alongside RSS; do not call reclaimable cache a leak. RSS can double-count shared pages.

## Repeatable test procedure

Run after a clean boot, wait three minutes after login, and close all applications:

```sh
uname -a
lscpu
systemd-analyze time
systemd-analyze blame
free -h
cat /proc/meminfo | grep -E 'MemTotal|MemAvailable|SwapTotal|SwapFree'
systemctl --type=service --state=running
ps -eo pid,comm,%cpu,rss --sort=-rss | head -n 20
```

If the UI is visibly laggy, also capture the graphics renderer and session:

```sh
printf 'Session: %s\nDesktop: %s\n' "${XDG_SESSION_TYPE:-unknown}" "${XDG_CURRENT_DESKTOP:-unknown}"
if command -v glxinfo >/dev/null 2>&1; then glxinfo -B; fi
systemctl --no-pager status vboxservice.service
pgrep -af 'VBoxClient|kwin_wayland|kwin_x11|plasmashell' || true
```

Record:
- RAM capacity assigned to the VM, vCPU count, VirtualBox version, and whether 3D acceleration is enabled
- host CPU/RAM pressure while the VM runs
- kernel and package snapshot/date
- display session (Wayland or X11) and graphics renderer
- idle memory and MemAvailable after three minutes
- swap use, running services, and top CPU/RSS processes
- whether firmware, Wi-Fi, Bluetooth, or desktop indexing changed the result

Compare 2 GiB, 3 GiB, and 4 GiB guest RAM with the same VM settings, then repeat on a real PC. A VM-only result is useful but does not replace hardware testing. Avoid changing multiple settings at once; otherwise, the cause of a change will be unclear.

## VirtualBox troubleshooting order

1. Confirm the VM disk is on an SSD and the host has free RAM.
2. Assign 2 vCPUs and 3–4 GiB RAM if the host can spare it; separately test the 2 GiB minimum target.
3. Use the VirtualBox VMSVGA graphics controller and test 3D acceleration both on and off. The faster option varies by host GPU and VirtualBox version.
4. Verify Guest Additions are running and check the reported graphics renderer. A software renderer can make window movement and animations painfully slow.
5. Only after collecting a report should we consider changing the default session, compositor behavior, or package set.

## Persistence is separate from memory optimization

The current live ISO is ephemeral: its writable layer and home directory do not provide durable storage across reboot. Making app folders more Windows-like cannot solve this. Persistence requires a tested installed system or an explicitly configured writable persistence disk/partition. Never automatically format a user's disk to implement persistence.

## Release criteria

- Publish the test setup and raw output.
- Demonstrate basic desktop responsiveness at 2 GiB, without claiming every game fits in that amount.
- Compare on the same hardware against a clearly defined upstream KDE baseline.
- Measure cold boot, idle memory, CPU usage, and gaming frame times separately.
- Investigate regressions instead of hiding them by changing the reported metric.
