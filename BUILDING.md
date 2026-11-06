# Building BOLT OS

## Supported build host

Use a current, fully updated x86_64 Arch Linux host with root access and a working official repository/mirror configuration. The build uses a separate root filesystem and work directory; do not build on a production machine with insufficient free storage. The build does not update the host packages, but it refreshes the package databases for resolution.

Install the tools:

```sh
sudo pacman -Syu --needed arch-install-scripts mkinitcpio squashfs-tools xorriso limine shellcheck git
```

Clone and build:

```sh
git clone https://github.com/BoltGamingOfficial/bolt-os.git
cd bolt-os
git switch delivery/bolt-clean-build
sudo env BOLT_VERSION=0.2.0-dev \\
  DELIVERY_DIR="$PWD/BOLT-OS-DELIVERY" \\
  WORK_DIR="/var/tmp/bolt-os-build" \\
  ./build.sh
```

The build creates a temporary pacman configuration containing only the official `core`, `extra`, and `multilib` repositories, so it does not require changing the host pacman configuration. It exits before rootfs creation if the host is not Arch Linux, required tools are missing, or any package in `packages.x86_64` cannot be resolved through the configured official repositories. It invokes ShellCheck and the local source/unit tests before package installation. It does not run an unverified third-party installer or modify a target disk.

The build creates:

```text
BOLT-OS-DELIVERY/
  iso/          BOLT-OS-<version>-x86_64.iso
  checksums/    ISO SHA-256 checksum file
  logs/         timestamped build log
  testing/      ISO structure report, file listing, and size measurements
```

Verify the checksum:

```sh
cd BOLT-OS-DELIVERY/iso
sha256sum -c ../checksums/BOLT-OS-0.2.0-dev-x86_64.iso.sha256
```

## Boot architecture

The ISO uses Limine 12, with a UEFI El Torito boot entry and a legacy-BIOS hybrid MBR boot path. The EFI CD boot image is used directly; the optional appended EFI System Partition stage is omitted because xorriso 1.5.8 failed to create that appended partition in the CI build. UEFI boot from optical media/VM is the target of the automated OVMF test; UEFI boot after writing the ISO to a USB stick is not yet claimed or tested. The kernel, microcode, and custom initramfs live under `/BOLT/boot/`; the root filesystem is `/BOLT/system.squashfs`; the filesystem label is `BOLT_LIVE`. The custom initramfs hook locates that label, mounts the ISO and squashfs, creates an overlay upper layer with a 50%-of-detected-RAM tmpfs size cap, moves the API filesystems, and switches to systemd in the overlay root.

The live initramfs and ISO boot entries are BOLT-defined. Arch packages remain the software source; this is not a new independent kernel or package ecosystem.

## Package and graphics choices

- `steam` comes from the multilib repository. The build always enables multilib in its temporary package-manager configuration without changing the host configuration.
- Intel and AMD Vulkan stacks use `vulkan-intel`, `vulkan-radeon`, and their `lib32-` packages.
- NVIDIA uses `nvidia-open` plus matching `nvidia-utils` and `lib32-nvidia-utils`, not multiple NVIDIA driver branches. This choice is for Turing-and-newer hardware; Maxwell, Pascal, and Volta-era GPUs are not claimed to be supported by this official-repository-only build.
- Lutris is the only extra launcher beyond Steam. GameMode, Gamescope, and MangoHud provide game-session optimization, compositor support, and overlays without persistent background services.

## VM and hardware test

A boot test requires QEMU with OVMF firmware on a host with virtualization enabled. After building, run the included UEFI probe (it locates OVMF firmware and falls back to TCG when KVM is unavailable):

```sh
QEMU_REPORT_DIR="$PWD/BOLT-OS-DELIVERY/testing" \\
  bash tests/qemu-uefi-smoke.sh "$PWD/BOLT-OS-DELIVERY/iso/BOLT-OS-0.2.0-dev-x86_64.iso"
```

The Arch `edk2-ovmf` package installs split UEFI firmware under `/usr/share/edk2/x64/OVMF_CODE.4m.fd` and `OVMF_VARS.4m.fd`; the included QEMU smoke script locates the pair automatically. First-run setup is intentionally interactive. After account creation and desktop login, run:

```sh
/usr/local/share/bolt-os/tests/vm-smoke-test.sh
```

The smoke test records memory, boot timing, resident processes, services, and core application availability. It does not replace manual display/audio tests, a Vulkan renderer check, Steam game launch, or hardware validation on each GPU vendor.

## Scope limitations

This deliverable builds a live ISO only. It has no Calamares integration, no partitioner, no disk-install mode, no filesystem creation, and no installed-system bootloader workflow. Do not try to install it to a disk or describe it as persistent. A separate installer must be engineered and tested before that claim is made.
