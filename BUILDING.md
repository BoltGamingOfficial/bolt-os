# Building the BOLT OS Live Prototype

## Status and scope

The repository has an initial Archiso-based **live-image build recipe**. This is not yet a validated release, and the project does not yet have a dedicated installer that lays down a complete BOLT OS installation on disk. Treat early images as experimental; do not replace your working operating system or store irreplaceable data on a test machine.

The build starts from the installed Archiso `releng` profile to preserve its supported boot infrastructure, then adds BOLT's package list and live-session overlay. See the current [Archiso documentation](https://wiki.archlinux.org/title/Archiso).

## Build host

Use a current x86-64 Arch Linux machine with enough free disk space for package caches, the working tree, and the generated ISO. Install the build tools:

```sh
sudo pacman -Syu --needed archiso shellcheck
```

Clone the repository, then run:

```sh
BOLT_VERSION=0.1.0-dev bash ./build.sh
```

Bluetooth support is installed but the daemon is not enabled at boot by default. To build an image that starts Bluetooth automatically, use `BOLT_ENABLE_BLUETOOTH=1`:

```sh
BOLT_VERSION=0.1.0-dev BOLT_ENABLE_BLUETOOTH=1 bash ./build.sh
```

The script expects `/usr/share/archiso/configs/releng` and the current Arch package repositories. You can select another installed releng profile with `ARCHISO_PROFILE=/path/to/releng`. Build output goes to `out/`; intermediate files go to `work/`. Override either with `OUT_DIR` or `WORK_DIR`.

## Writable storage in the live session

Archiso's default writable copy-on-write overlay is only 256 MiB. That is too
small for this gaming image: game launchers and applications may download large
asset caches into the live filesystem. The BOLT build script adds
`cow_spacesize=1G` to the supported systemd-boot, GRUB, and Syslinux kernel
command lines, giving the overlay a **1 GiB maximum**. This tmpfs limit grows on
demand; it does not reserve 1 GiB at boot, but using it still consumes RAM as
files are written. It is a temporary live-session limit, not persistent disk
space, and its contents disappear when the session ends.

For large game downloads, allocate enough RAM to the VM (4 GiB or more is a
more sensible starting point than 2 GiB) and monitor `free -h` alongside
`df -h /`. If the overlay fills again, inspect both the actual writable
filesystem and available memory before increasing the limit further.

Building an Arch ISO is supported on Arch Linux. Other environments can work but are not our initial supported build host. Run the build with the permissions required by your Archiso version.

## VirtualBox guest integration

The ISO package list includes Arch's `virtualbox-guest-utils` package, and the build enables `vboxservice.service`. The package supplies guest-side integration helpers, including `VBoxClient` autostart for desktop sessions. This is intended to improve pointer integration, dynamic display sizing, clipboard sharing, and drag-and-drop in VirtualBox guests.

**The host VM must also allow these features.** On the Windows host, fully shut down the VM and open VirtualBox Manager → select the BOLT VM → **Settings → General → Advanced**. Set **Shared Clipboard** to **Bidirectional** and **Drag'n'Drop** to **Bidirectional**. If the options are disabled or integration still does not work, check the VirtualBox host version and guest session type. Guest Additions and the host VirtualBox version should be compatible; clipboard and drag-and-drop support can vary by display session, so try a Plasma X11 session if the Wayland session does not provide the required integration.

This support is specifically for VirtualBox. Other hypervisors do not gain their guest tools from this package. Host-side options are not changed automatically by the ISO.

## Persistence: important limitation

The live ISO is ephemeral. Files and user settings created only inside the live session—including Prism Launcher instances, account tokens, browser profiles, and desktop settings—can disappear when the VM reboots. This is expected behavior for the current prototype, not a safe persistent installation.

Do not store important accounts or files only in a live ISO session. An installed BOLT OS needs a dedicated installer and a tested on-disk installation path; those are not implemented yet. Persistence is a release blocker and must be tested across reboot and full shutdown before we describe an installed release as usable.

## Test before distribution

After a successful build, verify the file hash and boot it in a virtual machine before using a USB stick:

```sh
(cd out && sha256sum -c SHA256SUMS)
run_archiso -i out/bolt-os-0.1.0-dev-x86_64.iso
```

The exact ISO filename is determined by the installed Archiso version and build profile; use `ls -lh out/` if it differs from the example. On the VM, verify:
- UEFI/BIOS boot path available in the image
- SDDM opens the KDE Plasma live desktop
- the default gold-and-black BOLT wallpaper is applied
- Wi-Fi/Ethernet, audio, Vulkan detection, and session shutdown work
- shared clipboard and drag-and-drop work after enabling them in VirtualBox host settings
- Steam starts only when manually launched
- no AI application starts at login
- the live-only user and passwordless sudo rule do not leak into a future disk installer
- memory measurements are recorded according to [[Memory Budget]]

## Important notes

- The default package list includes Steam and gaming utilities, but they do not need to run in the background.
- VirtualBox guest integration is included for convenience but is not a substitute for testing on physical hardware or other hypervisors.
- The live ISO is ephemeral; files and user settings do not survive a reboot unless explicitly saved elsewhere.
- An installable release needs a separate, tested installer and post-install setup path. Do not mistake the live desktop for that installer.
- Arch Linux is rolling release, so rebuild and test periodically against current packages.
