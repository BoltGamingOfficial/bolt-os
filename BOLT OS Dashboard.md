# BOLT OS Dashboard

> [!abstract] Mission
> Build a customizable, gaming-first Linux OS that stays lean, looks sharp, and respects the user's control over their own PC.

## Project notes

- [[Vision and Goals|Vision and goals]]
- [[System Architecture|System architecture]]
- [[Gaming Experience|Gaming stack]]
- [[Hardware Compatibility|Hardware and driver support]]
- [[Branding|Visual identity]]
- [[Memory Budget|Memory budget]]
- [[Roadmap|Roadmap]]
- [[Open Questions|Decisions to make]]
- [Building the prototype](BUILDING.md)
- [[AI Hub - OpenCode|Optional OpenCode tool]]

## Principles

1. **Gaming first:** prioritize reliable game launching, drivers, Vulkan, controllers, and performance tools.
2. **Lean by default:** avoid unnecessary background services.
3. **User choice:** make appearance and optional components configurable.
4. **OpenCode stays optional:** useful for people who want it; not part of the OS identity.
5. **Honest compatibility:** document tested hardware and known limitations.
6. **Test before claiming:** validate boot, updates, graphics, and gaming in VMs and on real hardware.

## Current status

- [x] Initial Archiso build recipe added
- [x] Focused KDE and gaming package list added
- [x] Live-session user, display manager, and wallpaper configuration drafted
- [x] Memory budget and test procedure documented
- [ ] Run first ISO build
- [ ] Boot the ISO in a VM and fix issues
- [ ] Test Intel, AMD, and NVIDIA graphics paths
- [ ] Establish actual performance and memory baselines
- [ ] Design and test a dedicated disk installer

## Working rule

A task is complete only when its output exists and relevant validation has been performed. A recipe is not a built ISO; a bootable live desktop is not yet a disk installer.
