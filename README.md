# BOLT OS

**A customizable, gaming-first Linux operating system.**

This repository is also the planning vault for [Obsidian](https://obsidian.md/). Open the repository folder as a vault to navigate the project notes.

> [!warning] Experimental development build
> BOLT OS is an early Archiso-based live prototype. CI can produce development ISO artifacts, but the current image has **not yet passed the complete boot, hardware, installer, persistence, or gaming release gates**. Do not replace a working operating system or use the image with irreplaceable data.

## Start here

- [[BOLT OS Dashboard]]
- [[Vision and Goals]]
- [[System Architecture]]
- [[Gaming Experience]]
- [[Hardware Compatibility]]
- [[Branding]]
- [[Roadmap]]
- [[Open Questions]]

## Build and test

- [Build instructions](BUILDING.md)
- [[Memory Budget]] — performance goals and measurement procedure
- [[Performance & RAM Integration Handoff]] — current evidence and outstanding work
- `build.sh` — shared Archiso build entry point
- [Development ISO workflow](https://github.com/BoltGamingOfficial/bolt-os/actions/workflows/build-iso-test.yml)
- [Repository quality checks](https://github.com/BoltGamingOfficial/bolt-os/actions/workflows/quality.yml)

## Current implementation

- **Base:** Arch Linux and upstream Archiso live-image infrastructure.
- **Desktop:** KDE Plasma with SDDM.
- **Gaming:** Steam, Lutris, Prism Launcher, Vulkan and 32-bit Vulkan libraries, GameMode, Gamescope, MangoHud.
- **Everyday app:** Firefox.
- **Networking/audio:** NetworkManager and PipeWire/WirePlumber.
- **Runtime policy:** game launchers do not autostart; Bluetooth packages are present but the daemon is opt-in at build time; OpenCode remains optional and user-launched.
- **Brand:** gold wallpaper with a black lightning bolt.

TLauncher is **not bundled** in the base image at this stage: it is not an official Arch repository package, so adding a third-party launcher binary without a verified source, integrity check, and security review would conflict with BOLT OS's transparency and user-control goals. It can be revisited as a clearly opt-in, user-installed application after that review.

## Release status

| Gate | Status |
|---|---|
| CI ISO build and checksum generation | Implemented; prior CI build succeeded for a development commit |
| Release ISO split into uploadable chunks | Implemented in the main-branch release workflow; verify the latest run's assets |
| Reproducible build from documented instructions | Not yet independently reproduced |
| UEFI boot and KDE live session | Must be tested on the exact artifact |
| Networking, audio, input, scaling, shutdown | Not fully verified |
| Installed-system installer | Not implemented |
| KDE/BOLT settings persistent across reboot and shutdown | Not verified; live sessions are ephemeral |
| Balanced/Gaming/Performance/Battery presets | Not implemented and tested end-to-end |
| RAM, boot, idle CPU, gaming frame-time measurements | Not recorded; performance targets are not claims |
| Physical hardware compatibility | Not yet established across Intel, AMD, and NVIDIA |

A successful workflow means the ISO was built and the artifact uploaded; it does not prove the ISO boots or works on physical hardware. Keep all development artifacts labeled experimental until the relevant gates are tested and recorded.
