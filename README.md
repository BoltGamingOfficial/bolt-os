# BOLT OS

**Development live-image source for a minimal KDE gaming desktop.** This repository is an experimental build recipe, not a stable release or an installer.

BOLT uses official Arch package repositories as its binary package source, but owns its live-image layout: Limine boot configuration, the `/BOLT/boot/` directory, the `/BOLT/system.squashfs` image, the `BOLT_LIVE` medium label, and a custom mkinitcpio hook. The ISO uses a UEFI El Torito boot entry and a GPT EFI system partition for hybrid optical-media and raw USB boot. It does not copy the standard Arch live-image profile or use the Arch ISO build framework.

## What is included

- KDE Plasma with a focused desktop shell, panel, launcher, system tray, network and audio applets, display controls, and power settings. The Xorg server is retained for SDDM greeter compatibility; the intended desktop session is Wayland.
- Firefox and Prism Launcher for browsing and Minecraft instances.
- Steam plus Lutris for PC game libraries. Lutris is the single additional PC game launcher.
- Wine, Wine Gecko/Mono and Winetricks for running and configuring many Windows applications. Compatibility varies; games using unsupported anti-cheat systems may not work through Wine.
- A **Roblox (Sober)** menu shortcut. On first launch it asks before installing the unofficial Sober Flatpak for the current user. Sober is closed-source, experimental community software, not made or supported by Roblox; it runs Roblox through a specialized Android runtime and can stop working after Roblox updates.
- Vulkan/OpenGL userspace for Intel and AMD Mesa drivers, plus NVIDIA's open kernel-module driver and matching userspace. 32-bit graphics and audio libraries are included for Steam/Proton.
- GameMode, Gamescope, and MangoHud.
- NetworkManager, PipeWire/WirePlumber, and power-profiles-daemon. Bluetooth is not installed or started.
- Gold-and-black BOLT branding in the Limine menu, SDDM theme, and Plasma wallpaper.
- A TTY first-run account wizard that collects a username, password and confirmation, timezone, and XKB keyboard layout before SDDM may start.

No AI agents, usage telemetry, advertising, or background game launchers are included. Firefox, Prism Launcher, Wine and Winetricks are installed but do not start automatically. The Sober runtime is downloaded only when the user opens the Roblox shortcut and accepts the notice. Steam, Lutris, Gamescope, and MangoHud do not start automatically.

## First boot and security

There is no pre-created desktop account and no default password. The root account is locked. The first-run wizard creates the user's account, hashes the password with OpenSSL SHA-512 crypt, installs the hash using `chpasswd --encrypted`, sets timezone and keyboard settings, and records completion without recording the password or hash. The SDDM unit requires successful first-run completion. The wheel sudo rule requires the user's password; there is no passwordless sudo or SDDM autologin.

If setup is cancelled or fails, SDDM remains blocked. Reboot to retry the first-run wizard.

## Terminal and package management

BOLT OS is Arch-based, not Debian-based. Use **pacman**, not **apt**. Examples:

```sh
sudo pacman -Syu                 # update installed packages
sudo pacman -S firefox           # install a package
sudo pacman -S prismlauncher wine winetricks
pacman -Qs firefox               # search installed packages
```

The `sudo` package is part of the image and the first-run account is added to `wheel`. The system login environment explicitly includes `/usr/bin` in `PATH`. There is no fake `apt` compatibility command.

## Live-image behavior

The image is ephemeral. The writable overlay is a tmpfs whose configured upper bound is 50% of detected physical RAM; tmpfs allocates memory as files are written, so the cap is not pre-reserved RAM and is not disk capacity. Changes are lost on reboot. A Plasma desktop plus Firefox, Wine, game launchers and Vulkan libraries cannot run in megabytes of RAM. Boot and startup are being optimized, but idle RAM must be measured on real hardware before publishing a number. The build report records ISO and compressed/uncompressed image sizes; idle RAM and installed disk footprint are deliberately not reported until measured on a booted system and a tested installer exists.

## Hardware scope

Target: x86_64 UEFI PCs with Intel or AMD CPUs. Intel and AMD Vulkan support uses Mesa. NVIDIA support uses the open kernel-module driver and is intended for Turing-generation and newer GPUs; older NVIDIA generations are not claimed to work with this build. The official kernel package may still expose its upstream Arch build suffix in `uname -r`; the distro does not yet carry a separately branded kernel build. Secure Boot is not configured or signed in this development image and should be disabled for testing.

## Build and validation

See [BUILDING.md](BUILDING.md) for a clean Arch Linux host procedure. The build validates package names against the enabled official repositories before installing them, runs source/unit/lint checks, creates a zstd-compressed root image, builds a UEFI hybrid Limine ISO, and writes SHA-256 checksums and logs. GitHub Actions on `main` runs source checks, builds the ISO, and performs a QEMU/OVMF UEFI boot probe.

**No installer is shipped.** The repository does not yet contain a safe disk installer, partitioning workflow, explicit disk-wipe confirmation, or tested installed-system bootloader setup. The live ISO must not be presented as an installable system and will not format any disk.

## Project status

Experimental development source. A release is not stable until the live image boots on UEFI VMs and physical Intel/AMD/NVIDIA hardware, first-run and authentication gates are verified, graphics and audio are tested, runtime memory is measured, and a separate safe installer has passed destructive-action and persistence tests.
