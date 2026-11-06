# BOLT OS 0.2.0-dev — release notes

## Engineering changes

- Replaced standard live-image profile inheritance with a BOLT-owned Limine boot tree, UEFI El Torito entry, legacy-BIOS hybrid MBR, `/BOLT` file layout, `BOLT_LIVE` label, and custom initramfs hook.
- Kept kernel and initramfs payloads outside the compressed root image to avoid duplicate boot data.
- Added zstd level-15 squashfs compression and build-time ISO/image size reporting.
- Removed the fixed live account, SDDM autologin, and passwordless sudo rule.
- Added an interactive TTY setup flow that creates the first account and applies a salted SHA-512 crypt password hash (minimum 12 characters), timezone, and keyboard layout before SDDM is allowed to start.
- Added a narrow password-required wheel sudo policy and locked the root account.
- Reduced the desktop package list; removed Bluetooth, web browser, extra game launcher overlap, and AI/developer agents from the default image.
- Selected Steam plus Lutris, with GameMode, Gamescope, MangoHud, Mesa Intel/AMD Vulkan, and NVIDIA open-driver userspace.
- Added source checks, first-run hash/validator tests, preset persistence tests, ShellCheck CI, and a separate Arch-host ISO build workflow.

## Not included

- No disk installer or partitioning UI.
- No persistent on-disk install or tested bootloader installation.
- No completed QEMU/OVMF boot verification or physical GPU matrix in this source delivery.
- UEFI boot from USB-written media is not included in the current boot claim; the automated target is UEFI optical/VM boot.
- The official Linux kernel release string may still include an Arch build suffix; a separately branded kernel build is not included.
- No idle RAM or installed disk-footprint benchmark until those measurements can be run against an actually booted image and an installable target.

This is an experimental development build recipe, not a release candidate or stable distribution.
