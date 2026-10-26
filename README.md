# BOLT OS

**A customizable, gaming-first Linux operating system.**

This repository is also the planning vault for [Obsidian](https://obsidian.md/). Open the repository folder as a vault to navigate the notes through their internal links.

> [!warning] Experimental prototype
> BOLT OS is in early development. The repository contains an initial live-image build recipe, but no ISO has yet been built and validated. Do not use it as a replacement for a working system.

## Start here

- [[BOLT OS Dashboard]]
- [[Vision and Goals]]
- [[System Architecture]]
- [[Gaming Experience]]
- [[Hardware Compatibility]]
- [[Branding]]
- [[Roadmap]]
- [[Open Questions]]

## Building

- [Build instructions](BUILDING.md)
- [[Memory Budget]] — lightweight desktop goals and measurement procedure
- `build.sh` — builds an Archiso-based live image on an Arch Linux x86-64 host
- [Manual ISO build workflow](https://github.com/BoltGamingOfficial/bolt-os/actions/workflows/build-iso.yml) — available under GitHub Actions

## Current direction

- Base: Arch Linux, using the upstream Archiso live-image infrastructure
- Desktop: KDE Plasma, using a deliberately focused package set
- Gaming: Steam, Lutris, Vulkan, GameMode, Gamescope, and MangoHud
- Runtime policy: game launchers do not autostart; OpenCode remains optional and user-launched
- Brand: gold background with a simple black lightning bolt

The first milestone is a bootable live prototype. A dedicated, tested installer for an installed BOLT OS system is still needed.
