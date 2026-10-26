# Gaming Experience

## Intended experience

A user should be able to install BOLT OS, reach the desktop, install or open a launcher, and understand how to troubleshoot common compatibility issues.

## Candidate components

- **Steam** for the main PC game library and Proton.
- **Proton-GE** as an optional compatibility choice.
- **Lutris** for managing games and launchers.
- **Heroic Games Launcher** for supported Epic Games Store and GOG workflows.
- **Vulkan** support through the correct vendor driver stack.
- **GameMode** for optional performance tuning.
- **Controller support** using Linux kernel and relevant userspace components.
- **MangoHud** or similar overlays as optional diagnostics.
- **Gamescope** where appropriate and compatible with the chosen session and hardware.

Package choices should be tested before inclusion in the default image.

## Performance policy

- Do not promise higher FPS without controlled benchmarks.
- Keep the baseline install lean without removing services needed for stability or security.
- Avoid aggressive CPU/GPU tuning by default.
- Make overlays and tuning tools easy to disable.
- Record average FPS, frame-time consistency, 1% lows where available, temperature, power behavior, and crashes.

## Compatibility caveats

Compatibility varies with each title, anti-cheat, DRM, launcher, Proton version, GPU driver, firmware, and peripherals. Consult upstream project documentation and community compatibility reports during release testing, and document per-title limitations.

## Test matrix

| Area | Test |
|---|---|
| Launchers | Install, sign in, update and launch |
| Graphics | Vulkan device detected; correct driver loaded |
| Controllers | USB and Bluetooth pairing and input |
| Audio | Headphones, microphone, game audio |
| Suspend/resume | Test where supported |
| Performance | Repeatable baseline on fixed hardware |
| Updates | System and launcher updates do not break startup |
