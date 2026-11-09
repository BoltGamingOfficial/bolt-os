# BOLT OS 0.3.1-dev — release notes

## Build artifact security and delivery
- CI now refreshes ClamAV signatures and scans the unpacked root filesystem before upload; a detection blocks publication.
- The ISO and its checksum are published as individual unzipped GitHub Actions artifacts, avoiding an extra ZIP wrapper that can trigger browser Safe Browsing false positives.

## Desktop and everyday applications
- Added Kate as the default text/source/configuration viewer and editor.
- Added VLC with its extra plugin collection as the default player for common audio and video containers/codecs.
- Added Gwenview with Qt/KDE image-format plugins as the default image viewer, plus Dolphin thumbnail providers for videos and additional graphics formats.
- Added explicit per-user MIME defaults for common text, audio, video, and image formats.

## Roblox / Sober
- Reworked the Sober launcher to diagnose CPU instruction support, kernel, virtualization, Vulkan/OpenGL devices, DRM render-node permissions, Flatpak installation, and XDG portal state.
- Added saved launch output and instructions for collecting Sober's own logs.
- Added the documented `use_opengl=true` fallback while preserving other valid settings in Sober's JSON configuration.
- Added a confirmed per-user clean-reinstall option; the launcher now checks Flatpak install scope and offers updates before launch.
- Added the `render` group to first-run GPU access where the group exists.
- Important: Sober's developers do not support virtual machines without GPU passthrough. The OpenGL option is a best-effort workaround and cannot guarantee that Sober will run in VirtualBox.

## Performance and terminal usability
- Retained the two-second Limine menu, fast initramfs compression and Zstandard level-6 SquashFS tuning.
- Added zram compressed swap sized to half of physical RAM (maximum 4 GiB), using LZ4 for low CPU overhead.
- Reduced default KDE animation duration and kept Baloo file indexing disabled.
- Added system and per-user Bash PATH setup to ensure Konsole can find /usr/bin tools.
- Added an apt-style convenience bridge for common commands, while documenting Arch's full-upgrade requirement and pacman package names.
- Added BOLT terminal help, Bash completion, and runtime checks for Konsole, sudo, pacman, Java and zram.

## Limitations
- VLC/Gwenview/Kate cover broad common formats, not every proprietary, DRM-protected, encrypted, corrupt, or unsupported file format.
- A KDE gaming desktop cannot operate in only a few megabytes of RAM. Zram provides compressed swap under pressure but is not additional physical memory. Idle RAM and boot time still require measurement on real hardware.
- Sober is unofficial, closed-source and experimental, and is not supported by Roblox. VirtualBox may not expose a usable Vulkan device; test on bare-metal Intel Iris Xe first.
- Wine and Proton compatibility varies by application and game.
- This remains an ephemeral live ISO without a disk installer.

BOLT OS is an experimental development build, not a stable distribution.
