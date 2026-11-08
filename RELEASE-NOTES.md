# BOLT OS 0.3.1-dev — release notes

## Desktop and gaming applications
- Bundled Firefox and Prism Launcher with OpenJDK 21.
- Retained Wine, Wine Gecko/Mono and Winetricks for Windows application compatibility, plus Steam/Proton and Lutris.
- Kept Roblox as an opt-in Sober Flatpak install from the desktop shortcut. Sober is unofficial, proprietary, experimental community software, not Roblox-supported.

## Performance and terminal usability
- Retained the two-second Limine menu, fast initramfs compression and Zstandard level-6 SquashFS tuning.
- Added zram compressed swap sized to half of physical RAM (maximum 4 GiB), using LZ4 for low CPU overhead.
- Reduced default KDE animation duration and kept Baloo file indexing disabled.
- Added system and per-user Bash PATH setup to ensure Konsole can find /usr/bin tools.
- Added an apt-style convenience bridge for common commands, while documenting Arch's full-upgrade requirement and pacman package names.
- Added BOLT terminal help, Bash completion, and runtime checks for Konsole, sudo, pacman, Java and zram.

## Limitations
- A KDE gaming desktop cannot operate in only a few megabytes of RAM. Zram provides compressed swap under pressure but is not additional physical memory. Idle RAM and boot time still require measurement on real hardware.
- Sober is unofficial, closed-source and experimental, and is not supported by Roblox. VirtualBox may not expose the Vulkan capability it needs; test on the physical Intel Iris Xe graphics stack.
- Wine and Proton compatibility varies by application and game.
- This remains an ephemeral live ISO without a disk installer.

BOLT OS is an experimental development build, not a stable distribution.
