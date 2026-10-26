# System Architecture

> [!warning] Proposed architecture
> These are initial design choices, not a finished implementation.

## Base and desktop

- **Base distribution:** Arch Linux, using maintained repositories and reproducible packaging practices.
- **Desktop environment:** KDE Plasma for a full graphical experience and extensive customization.
- **Architecture:** initially target x86-64 PCs. ARM support, if ever desired, needs a separate scope and test plan.
- **Boot/install:** evaluate a reproducible live ISO and a supported installation workflow before choosing extra tooling.

## Layers

1. **Base system:** kernel, systemd, networking, audio, firmware, security updates.
2. **Graphics:** Mesa/Vulkan for supported Intel and AMD devices; NVIDIA driver path selected based on hardware and kernel compatibility.
3. **Desktop:** KDE Plasma, display manager, settings, accessibility and power management.
4. **Gaming:** Steam, Proton support, Lutris, Heroic, GameMode, controller support and diagnostics.
5. **BOLT tools:** first-run setup, hardware detection, optional feature management and support diagnostics.
6. **AI hub:** OpenCode launcher/configuration, provider setup and credential guidance.

## Design constraints

- Keep AI and optional launchers separate from the core boot path.
- Prefer official/upstream packages where practical.
- Avoid enabling duplicate services that compete for power, audio, network, or game sessions.
- Provide clear update and recovery paths.
- Detect GPU and offer documented fallbacks; do not silently force a driver that is unsuitable for the machine.
- Avoid hard-coding user secrets into configuration, logs, or repository files.

## Build plan

1. Define the minimum supported hardware and first release scope.
2. Create a reproducible Arch-based image configuration.
3. Add packages in small, reviewable groups.
4. Build and boot in a VM.
5. Test installer, updates, network, audio, and graphics.
6. Test gaming and AI features independently.
7. Publish checksums, build instructions, known issues, and release notes with any ISO.

## Architecture decisions still open

See [[Open Questions]].
