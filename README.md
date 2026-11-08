# BOLT OS

**Development live-image source for a minimal KDE gaming desktop.** This repository is an experimental build recipe, not a stable release or an installer.

BOLT uses official Arch package repositories as its binary package source, but owns its live-image layout: Limine boot configuration, the `/BOLT/boot/` directory, the `/BOLT/system.squashfs` image, the `BOLT_LIVE` medium label, and a custom mkinitcpio hook. The ISO uses a UEFI El Torito boot entry and a GPT EFI system partition for hybrid optical-media and raw USB boot. It does not copy the standard Arch live-image profile or use the Arch ISO build framework.

## What is included

- KDE Plasma with a focused desktop shell, panel, launcher, system tray, network and audio applets, display controls, and power settings. The Xorg server is retained for SDDM greeter compatibility; the intended desktop session is Wayland.
- Firefox and Prism Launcher for browsing and Minecraft instances.
- **Kate** opens plain text, source code, logs and configuration files; **VLC** is the default audio/video player for common containers and codecs; **Gwenview** is the default image viewer. Qt/KDE image-format plugins, VLC extra plugins, and Dolphin video/image thumbnail providers broaden format support. Unrecognized extensions can still be opened with the app's Open With menu.
- Steam plus Lutris for PC game libraries. Lutris is the single additional PC game launcher.
- Wine, Wine Gecko/Mono and Winetricks for running and configuring many Windows applications. Compatibility varies; games using unsupported anti-cheat systems may not work through Wine.
- A **Roblox (Sober)** menu shortcut with CPU/VM/GPU/Vulkan/Flatpak/portal diagnostics, launch-log capture, and an optional documented OpenGL fallback. On first launch it asks before installing the unofficial Sober Flatpak for the current user. Sober is closed-source, experimental community software, not made or supported by Roblox; it runs Roblox through a specialized Android runtime and can stop working after Roblox updates.
- Vulkan/OpenGL userspace for Intel and AMD Mesa drivers, plus NVIDIA's open kernel-module driver and matching userspace. 32-bit graphics and audio libraries are included for Steam/Proton.
- GameMode, Gamescope, and MangoHud.
- NetworkManager, PipeWire/WirePlumber, power-profiles-daemon, and zram compressed swap for occasional memory pressure. Bluetooth is not installed or started.
- Gold-and-black BOLT branding in the Limine menu, SDDM theme, and Plasma wallpaper.
- A TTY first-run account wizard that collects a username, password and confirmation, timezone, and XKB keyboard layout before SDDM may start.

No AI agents, usage telemetry, advertising, or background game launchers are included. Firefox, Prism Launcher, Wine and Winetricks are installed but do not start automatically. The Sober runtime is downloaded only when the user opens the Roblox shortcut and accepts the notice. Steam, Lutris, Gamescope, and MangoHud do not start automatically.

## File handling

New accounts default to Kate for common text and source/configuration MIME types, VLC for common audio/video types, and Gwenview for common image types. VLC's extra plugin package and the KDE/Qt image plugins add format coverage. No single player or image viewer can decode every proprietary, damaged, encrypted, or unusual format; use Dolphin's **Open With** option for unknown extensions and install a compatible codec/plugin when needed.

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

The `sudo` package is part of the image and the first-run account is added to `wheel`. `/usr/bin` is added to the system login environment, login profile, and new users' interactive Bash configuration. The `apt` convenience command translates common `update`, `upgrade`, `install`, `remove`, `search`, and `show` operations into pacman actions. On Arch, `apt update` and `apt install` deliberately perform a full `pacman -Syu` because partial upgrades are unsupported; package names and repositories differ from Debian/Ubuntu.

## Live-image behavior

The image is ephemeral. The writable overlay is a tmpfs whose configured upper bound is 50% of detected physical RAM; tmpfs allocates memory as files are written, so the cap is not pre-reserved RAM and is not disk capacity. Zram adds compressed swap capacity under pressure but does not create physical RAM. The KDE desktop and its browser, launchers and games cannot run in a few megabytes. The defaults reduce startup delay and animation overhead, but idle memory must be measured on real hardware before publishing a number. Changes to the live overlay are lost on reboot.

## Hardware scope

Target: x86_64 UEFI PCs with Intel or AMD CPUs. Intel and AMD Vulkan support uses Mesa. NVIDIA support uses the open kernel-module driver and is intended for Turing-generation and newer GPUs; older NVIDIA generations are not claimed to work with this build. The official kernel package may still expose its upstream Arch build suffix in `uname -r`; the distro does not yet carry a separately branded kernel build. Secure Boot is not configured or signed in this development image and should be disabled for testing.

## Build and validation

See [BUILDING.md](BUILDING.md) for a clean Arch Linux host procedure. The build validates package names against the enabled official repositories before installing them, runs source/unit/lint checks, creates a zstd-compressed root image, builds a UEFI hybrid Limine ISO, and writes SHA-256 checksums and logs. GitHub Actions on `main` runs source checks, builds the ISO, and performs a QEMU/OVMF UEFI boot probe.

**No installer is shipped.** The repository does not yet contain a safe disk installer, partitioning workflow, explicit disk-wipe confirmation, or tested installed-system bootloader setup. The live ISO must not be presented as an installable system and will not format any disk.

## Project status

Experimental development source. A release is not stable until the live image boots on UEFI VMs and physical Intel/AMD/NVIDIA hardware, first-run and authentication gates are verified, graphics and audio are tested, runtime memory is measured, and a separate safe installer has passed destructive-action and persistence tests.
