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

Building an Arch ISO is supported on Arch Linux. Other environments can work but are not our initial supported build host. Run the build with the permissions required by your Archiso version.

## Test before distribution

After a successful build, verify the file hash and boot it in a virtual machine before using a USB stick:

```sh
(cd out && sha256sum -c SHA256SUMS)
run_archiso -i out/bolt-os-0.1.0-dev-x86_64.iso
```

The exact ISO filename is determined by the installed Archiso version and build profile; use `ls -lh out/` if it differs from the example. On the VM, verify:
- UEFI/BIOS boot path available in the image
- SDDM opens the KDE Plasma live desktop
- Wi-Fi/Ethernet, audio, Vulkan detection, and session shutdown work
- Steam starts only when manually launched
- no AI application starts at login
- the live-only user and passwordless sudo rule do not leak into a future disk installer
- memory measurements are recorded according to [[Memory Budget]]

## Important notes

- The default package list includes Steam and gaming utilities, but they do not need to run in the background.
- The live ISO is ephemeral; files and user settings do not survive a reboot unless explicitly saved elsewhere.
- An installable release needs a separate, tested installer and post-install setup path. Do not mistake the live desktop for that installer.
- Arch Linux is rolling release, so rebuild and test periodically against current packages.
