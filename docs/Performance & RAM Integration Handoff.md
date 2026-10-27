# Performance & RAM Integration Handoff

**Review date:** 2026-10-27  
**Repository reviewed:** `BoltGamingOfficial/bolt-os`, branch `main`, commit `e01967a7dd03befff2909eb8d718160fc50d7c66`  
**Scope:** One unified Archiso live ISO with KDE Plasma and the gaming package set.

## 1. Current performance status

BOLT OS has a documented memory budget and several source-level choices intended to avoid unnecessary background activity. The repository also has a working CI build path that completed successfully for the current main commit and published a development prerelease. This is evidence that the automated build and asset publication ran, **not** evidence that the ISO boots, the desktop works, or performance targets are met.

| Area | Status | Evidence / limitation |
|---|---|---|
| Archiso build recipe | **Implemented; CI build tested** | `build.sh`; GitHub Actions run for commit `e01967a7...` completed successfully on 2026-10-26. |
| Development ISO artifact | **Built by CI; artifact published** | `v0.1.0-dev` prerelease contains split ISO parts and `SHA256SUMS`. The source record does not prove that the reconstructed image was boot-tested. |
| KDE Baloo indexing | **Implemented in source; runtime unverified** | `airootfs/etc/xdg/baloofilerc` sets `Indexing-Enabled=false`. |
| No launcher/AI autostart | **Design documented; runtime unverified** | `docs/Memory Budget.md` and package set; no launcher autostart was intentionally added. Verify the final desktop session. |
| Idle RAM ≤ 1.5 GiB | **Planned target; unverified** | No measured RAM results were found in the reviewed repository or available chat history. |
| Boot/login time, idle CPU, disk footprint, frame times | **Unverified** | No baseline output/results found. |
| VM and physical hardware validation | **Planned** | Roadmap leaves first boot and hardware validation incomplete. |
| Installer | **Planned / not implemented** | Current artifact is a live prototype, not an installable release. |

## 2. Implemented changes and evidence

### Implemented in repository source

- `docs/Memory Budget.md`: defines the idle-memory target, explains Linux cache and `MemAvailable`, calls for PSS as well as RSS, and documents a three-minute post-login settling period.
- `airootfs/etc/xdg/baloofilerc`: disables Baloo indexing by default in the live prototype to avoid an unexpected first-login indexing workload. Users can re-enable indexing in KDE settings.
- `packages.x86_64`: includes KDE Plasma components, PipeWire audio, NetworkManager, Bluetooth, Vulkan packages, Steam, Lutris, GameMode, Gamescope, MangoHud, and inspection tools. Installing a launcher does not mean it runs in the background.
- `build.sh`: copies the installed Archiso `releng` profile into a temporary profile, merges BOLT packages, enables multilib for Steam/32-bit dependencies, copies the `airootfs` overlay, and configures NetworkManager and SDDM.
- `.github/workflows/build-iso.yml`: checks shell syntax and ShellCheck, builds in an Arch container, uploads an ISO/checksum workflow artifact, splits release assets to fit GitHub's per-file upload limit, and publishes a prerelease.
- The CI workflow contains build-environment cache cleanup steps. These are **build-runner disk-space measures**, not runtime RAM optimizations in the shipped OS.

### Not demonstrated by the evidence

- No confirmed reduction in RAM, CPU use, boot time, or game frame times.
- No service has been shown by measurement to be a major idle resource consumer.
- No successful physical-machine test is recorded.
- A successful workflow run is not a boot test.

## 3. RAM and performance measurements

**No actual runtime measurements were found.** Do not fill in estimated values or report the 1.5 GiB target as achieved.

| Measurement | Actual result | Test environment | Status |
|---|---|---|---|
| Idle RAM after 3 minutes | Not recorded | Not recorded | **Unverified** |
| `MemAvailable`, swap usage/pressure | Not recorded | Not recorded | **Unverified** |
| Process PSS / RSS | Not recorded | Not recorded | **Unverified** |
| Boot time / userspace time | Not recorded | Not recorded | **Unverified** |
| Running services and failed units | Not recorded | Not recorded | **Unverified** |
| Idle CPU | Not recorded | Not recorded | **Unverified** |
| Root filesystem / installed footprint | Not recorded | Not recorded | **Unverified** |
| Gaming FPS and frame-time consistency | Not recorded | Not recorded | **Unverified** |

### Required measurement record

For each run, record date, ISO checksum or commit, physical machine or VM, CPU, RAM allocated, GPU/graphics acceleration and VRAM allocation where relevant, firmware/UEFI setting if relevant, kernel/package snapshot, Wayland or X11, time since login, whether applications were open, network/Bluetooth/indexing state, and the raw command output.

Run from a terminal after a clean boot and login, close applications, wait three minutes, then collect:

```sh
date -Is
uname -a
systemd-analyze time
systemd-analyze blame
systemd-analyze --failed
free -h
cat /proc/meminfo | grep -E 'MemTotal|MemAvailable|SwapTotal|SwapFree'
vmstat 1 5
ps -eo pid,comm,%cpu,%mem,rss --sort=-rss | head -15
systemctl --type=service --state=running
df -h /
```

For process comparisons, add proportional set size (PSS) using a suitable tool such as `smem` if installed, or inspect `/proc/<pid>/smaps_rollup`. Do not sum RSS as though shared pages were unique. Distinguish process memory from filesystem cache; `free`'s “used” value alone is not the release metric.

The current documented target is no more than **1.5 GiB of process memory attributable to the idle desktop and enabled services** on a defined 8 GiB x86-64 reference system, after login and a three-minute settling period. Before pass/fail, define the exact accounting method, whether graphics allocations are included, and the measurement tool. Repeat on 4 GiB and at least one physical PC. VM results are useful for regression tracking but do not prove physical-hardware performance.

## 4. Recommended optimizations ranked by impact and risk

Ranks below are engineering priorities, not measured savings.

| Priority | Proposal | Expected impact | Risk | Status / guidance |
|---|---|---|---|---|
| 1 | Establish repeatable RAM, boot, CPU and service baselines | High diagnostic value | Low | **Planned.** Do before tuning. |
| 2 | Confirm only intended services are enabled; inspect boot blame and failed units | Medium, hardware-dependent | Low if observational | **Planned.** Inventory first; do not blanket-disable services. |
| 3 | Verify Baloo is actually disabled in the booted session | Low–medium, workload-dependent | Low | **Implemented in config; runtime unverified.** |
| 4 | Review optional Bluetooth enablement | Small/variable | Medium | **Review needed.** `build.sh` currently enables `bluetooth.service` unconditionally, while memory-budget policy says enable Bluetooth support when requested. Decide whether live prototype convenience outweighs always-on service cost; test adapters/controllers before changing. |
| 5 | Remove accidental autostarts and duplicate services | Potentially medium | Medium | **Planned.** Check KDE autostart, systemd wants, and actual process list. NetworkManager is intentionally selected instead of systemd-networkd/resolved in this profile. |
| 6 | Review KDE components and effects only after baseline | Variable | Medium | **Planned.** Preserve desktop usability, accessibility, portals, audio, power management, and expected Wayland behavior. |
| 7 | Measure image/package footprint and remove only demonstrably unnecessary packages | Potential disk savings; not automatically RAM savings | Medium | **Planned.** Closed applications generally do not consume their full installed footprint as runtime RAM. |
| 8 | Tune kernel parameters, swappiness, zram, CPU governor, or service timeouts | Unknown before measurement | Medium–high | **Not recommended yet.** Introduce only with a specific measured problem and rollback test. |

Avoid removing Steam, Lutris, Vulkan libraries, GameMode, Gamescope, MangoHud, firmware, networking, PipeWire, or core KDE components merely to improve an idle screenshot. Do not add a memory-cleaning daemon or background “optimizer” without evidence that it solves a real problem.

## 5. Files and configuration changes ready for integration

The following are already in `main`; do not duplicate them in a second ISO profile.

| Path | Current state | Integration note |
|---|---|---|
| `docs/Memory Budget.md` | **Implemented** | Source of truth for target and measurement procedure. Keep claims aligned with actual results. |
| `packages.x86_64` | **Implemented** | Shared gaming/KDE package manifest. Coordinate changes with Gaming & Compatibility. |
| `build.sh` | **Implemented; CI build tested** | Single Archiso build entry point; avoid creating a separate performance ISO. |
| `airootfs/etc/xdg/baloofilerc` | **Implemented in source** | Live prototype Baloo default. Verify effective configuration after boot. |
| `airootfs/etc/systemd/system/bolt-live-user.service` | **Implemented in source** | One-shot live-user provisioning before display manager; not a tuning target without evidence. |
| `airootfs/etc/systemd/system/bolt-live-user.service` and `airootfs/usr/local/libexec/bolt-create-live-user` | **Implemented in source** | Preserve live-session functionality and ensure live-only credentials do not enter any future installed system. |
| `.github/workflows/build-iso.yml` | **Implemented; one current successful run** | CI build and artifact/release publishing; does not boot-test the ISO or measure runtime performance. |

No runtime-tuning script or new systemd override was created in the Performance & RAM chat. Do not claim otherwise.

## 6. Potential conflicts with other development areas

- **Gaming & Compatibility:** Steam needs multilib and 32-bit Vulkan support. Preserve the relevant libraries and test the actual GPU path. Current manifest lists Intel, AMD and Nouveau Vulkan packages; it does not by itself establish proprietary NVIDIA support. GameMode, Gamescope and MangoHud should remain available without being auto-started.
- **Desktop & Branding:** KDE Plasma and SDDM are part of the memory baseline. Wallpaper setup runs through a one-shot user-session autostart; assess it for correctness, but do not treat a tiny one-shot action as a significant RAM optimization without evidence. Avoid disabling KDE portals or desktop components without testing.
- **Utilities / networking / audio:** NetworkManager, PipeWire/WirePlumber, udisks2 and polkit serve expected desktop functions. The build script removes links for systemd-networkd, systemd-resolved and wait-online and points `/etc/resolv.conf` to NetworkManager. Test DHCP, DNS, reconnect, audio, Bluetooth/controller support, suspend/resume where in scope, and shutdown.
- **Build & Debugging:** The CI cache cleanup reduces temporary runner disk pressure only. Keep it separate from claims about the installed OS's RAM. A CI pass is build evidence, not VM boot or physical compatibility evidence.
- **Installer:** Live-user creation and passwordless sudo are live-image-only choices. Any future installer must explicitly exclude live-only credentials and policies from installed systems.
- **Product philosophy:** Keep OpenCode optional and user-launched. No AI or other background agent should be added to the boot path.

## 7. Outstanding questions and unverified claims

1. Which exact reference hardware or VM defines the 8 GiB test? Record CPU, GPU, graphics acceleration and display session.
2. What exact metric constitutes the 1.5 GiB pass condition: process PSS, a defined process/service sum, or another explicitly documented measure? Do not mix it with system-wide “used” RAM.
3. Does Baloo remain disabled after the first Plasma login?
4. Is Bluetooth meant to be enabled by default in the live image, or only when requested?
5. Does the current prerelease ISO boot into SDDM and a usable Plasma session in both UEFI and the chosen legacy path?
6. Do DNS, networking, audio, Vulkan, Steam startup, controller support and shutdown work?
7. Which physical Intel, AMD and NVIDIA devices and games will be the initial compatibility/benchmark matrix?
8. How are test outputs and the tested ISO checksum stored with releases?
9. CI has had both a failed run and a later successful run. Review the failure logs if the failure's root cause has not already been documented; do not infer it from the commit message alone.

## 8. Testing plan for the next unified ISO

### Stage A — Build and artifact integrity

1. Build from the current shared `main` source using `bash ./build.sh` on the documented Arch build host, or inspect the existing CI artifact.
2. Confirm an ISO exists and record its size and SHA-256.
3. Verify with `(cd out && sha256sum -c SHA256SUMS)`.
4. Record commit SHA, package snapshot/build date, and build logs. Do not treat the split release parts as a bootable image until reassembled and checksum-verified.

### Stage B — VM smoke test

1. Boot the same ISO in a VM with 8 GiB RAM and documented virtual graphics settings; test UEFI and any supported alternate boot path.
2. Verify SDDM, KDE Plasma, wallpaper, keyboard/input, networking/DNS, audio, shutdown/reboot, and no unexpected launcher/AI autostart.
3. Confirm `systemd-analyze --failed`, running services, Vulkan visibility and Steam startup behavior.
4. Capture the complete three-minute idle measurement set. Repeat with 4 GiB RAM as a pressure/robustness check.
5. Record issues instead of changing the measurement conditions to make the target pass.

### Stage C — Physical hardware and gaming

1. Test at least one physical system, then expand to Intel, AMD and NVIDIA according to available hardware.
2. Record GPU, driver, kernel, session type, resolution and power state.
3. Test network, audio, Bluetooth/controllers where available, suspend/resume if supported, and clean shutdown.
4. Measure repeatable game frame times/FPS separately from idle RAM. Compare the same game, scene, settings and driver across runs.
5. Compare against a clearly defined upstream KDE/Arch baseline on the same hardware.

### Stage D — Optimization loop

1. Pick one suspected consumer based on measured evidence.
2. Change one variable at a time in the shared profile.
3. Rebuild, checksum, boot, repeat the same measurements, and test affected functionality.
4. Keep or revert based on measured benefit and regression risk.
5. Update this handoff and `docs/Memory Budget.md` with raw outputs and conclusions.

## 9. Integration checklist

- [ ] Keep one shared Archiso profile/build path; no separate performance ISO.
- [ ] Preserve the current KDE, networking, audio, Vulkan and gaming package requirements.
- [ ] Keep Baloo's current default until runtime verification; document user choice.
- [ ] Decide Bluetooth default behavior after reviewing the current unconditional enablement.
- [ ] Record the exact ISO commit, checksum, hardware/VM configuration and session type.
- [ ] Complete VM boot and desktop/network/audio/shutdown smoke tests.
- [ ] Capture the idle measurements after the documented three-minute settling period.
- [ ] Run the 4 GiB test and at least one physical-hardware test.
- [ ] Test gaming frame times independently from idle RAM.
- [ ] Label results as **Implemented**, **Tested**, **Partially Tested**, **Planned**, or **Unverified**.
- [ ] Do not mark the 1.5 GiB goal achieved until the documented metric passes on the defined reference system.
- [ ] Keep the ISO labelled experimental/development until boot, functionality, and compatibility claims are supported.

## Summary

The integration-ready performance work is currently the **shared configuration and measurement policy**, not a set of proven RAM reductions. The current repository has a successful CI build/release path and a published development ISO artifact, but the performance and boot validation gates remain open. Measure the existing unified image first, then make small changes based on evidence.
