# BOLT OS

**Development live-image source for a minimal KDE gaming desktop.** This branch is an experimental build recipe, not a stable release or an installer.

BOLT uses official Arch package repositories as its binary package source, but owns its live-image layout: Limine boot configuration, the `/BOLT/boot/` directory, the `/BOLT/system.squashfs` image, the `BOLT_LIVE` medium label, and a custom mkinitcpio hook. The image uses UEFI El Torito boot for optical media/VMs. It is not a BIOS image or a hybrid USB image; booting after writing it to a USB stick is not supported or claimed. It does not copy the standard Arch live-image profile or use the Arch ISO build framework.

## What is included

- KDE Plasma with a focused desktop shell, panel, launcher, system tray, network and audio applets, display controls, and power settings. The Xorg server is retained for SDDM greeter compatibility; the intended desktop session is Wayland.
- Steam plus Lutris. Lutris is the single additional game launcher: it covers non-Steam libraries and game installers without adding multiple overlapping launcher frontends.
- Vulkan/OpenGL userspace for Intel and AMD Mesa drivers, plus NVIDIA's open kernel-module driver and matching userspace. 32-bit graphics and audio libraries are included for Steam/Proton.
- GameMode, Gamescope, and MangoHud.
- NetworkManager, PipeWire/WirePlumber, and power-profiles-daemon. Bluetooth is not installed or started.
- Gold-and-black BOLT branding in the Limine menu, SDDM theme, and Plasma wallpaper.
- A TTY first-run account wizard that collects a username, password and confirmation, timezone, and XKB keyboard layout before SDDM may start.

No AI agents, usage telemetry, advertising, or background game launchers are included. Steam, Lutris, Gamescope, and MangoHud do not start automatically.

## First boot and security

There is no pre-created desktop account and no default password. The root account is locked. The first-run wizard creates the user's account, hashes the password with OpenSSL SHA-512 crypt, installs the hash using `chpasswd --encrypted`, sets timezone and keyboard settings, and records completion without recording the password or hash. The SDDM unit requires successful first-run completion. The wheel sudo rule requires the user's password; there is no passwordless sudo or SDDM autologin.

If setup is cancelled or fails, SDDM remains blocked. Reboot to retry the first-run wizard.

## Live-image behavior

The image is ephemeral. The writable overlay is a tmpfs whose configured upper bound is 50% of detected physical RAM; tmpfs allocates memory as files are written, so the cap is not pre-reserved RAM and is not disk capacity. Changes are lost on reboot. The build report records ISO and compressed/uncompressed image sizes; idle RAM and installed disk footprint are deliberately not reported until measured on a booted system and a tested installer exists.

## Hardware scope

Target: x86_64 UEFI PCs with Intel or AMD CPUs. Intel and AMD Vulkan support uses Mesa. NVIDIA support uses the open kernel-module driver and is intended for Turing-generation and newer GPUs; older NVIDIA generations are not claimed to work with this build. The official kernel package may still expose its upstream Arch build suffix in `uname -r`; the distro does not yet carry a separately branded kernel build. Secure Boot is not configured or signed in this development image and should be disabled for testing.

## Build and validation

See [BUILDING.md](BUILDING.md) for a clean Arch Linux host procedure. The build validates package names against the enabled official repositories before installing them, runs source/unit/lint checks, creates a zstd-compressed root image, builds a UEFI El Torito Limine ISO for optical/VM boot, and writes SHA-256 checksums and logs.

**No installer is shipped.** The repository does not yet contain a safe disk installer, partitioning workflow, explicit disk-wipe confirmation, or tested installed-system bootloader setup. The live ISO must not be presented as an installable system and will not format any disk.

## Project status

Experimental development source. A release is not stable until the live image boots on UEFI VMs and physical Intel/AMD/NVIDIA hardware, first-run and authentication gates are verified, graphics and audio are tested, runtime memory is measured, and a separate safe installer has passed destructive-action and persistence tests.
