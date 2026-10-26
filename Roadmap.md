# Roadmap

## Phase 0 — Define the project
- [x] Collect core ideas in an Obsidian-friendly vault
- [x] Record initial architecture, goals, and product principles
- [x] Define the idle-memory measurement target in [[Memory Budget]]
- [x] Add the first Archiso live-image build recipe
- [ ] Resolve remaining decisions in [[Open Questions]]

## Phase 1 — Build a bootable prototype
- [x] Add focused KDE and gaming package list
- [x] Configure live desktop user and display manager
- [x] Add the gold/black BOLT wallpaper
- [x] Add a manually triggered ISO build workflow
- [ ] Run the first ISO build
- [ ] Boot ISO in a virtual machine
- [ ] Fix any build, boot, network, audio, or session issues
- [ ] Record initial idle-memory and boot-time measurements

## Phase 2 — Validate gaming foundations
- [x] Include Steam and gaming utilities in the prototype package set
- [x] Include 64-bit and 32-bit Intel, AMD and Nouveau Vulkan drivers
- [ ] Verify the GPU and Vulkan detection paths
- [ ] Test Steam launch and game compatibility
- [ ] Evaluate NVIDIA's proprietary-driver setup and document the supported path
- [ ] Test controller, audio, and suspend/resume behavior
- [ ] Record repeatable performance baselines

## Phase 3 — Make it installable
- [ ] Select an installer approach that installs the BOLT package/configuration set
- [ ] Ensure live-only credentials and sudo rules do not carry into installed systems
- [ ] Add first-run user creation and hardware checks for installed systems
- [ ] Test install, reboot, update, and recovery paths

## Phase 4 — Finish the BOLT experience
- [ ] Set and test default desktop theme, panel, and wallpaper
- [ ] Review all enabled services and optional features
- [ ] Add safe support diagnostics
- [ ] Keep OpenCode documented as optional developer tooling

## Phase 5 — Release readiness
- [ ] Test on real Intel, AMD and NVIDIA systems
- [ ] Test system updates and recovery
- [ ] Publish known issues and compatibility notes
- [ ] Automate repeatable checks
- [ ] Build, checksum and test a release candidate

## Rule for closing tasks

A task is complete only when its output exists and relevant validation has been performed. Planning a feature is not implementation; a build recipe is not a built ISO; a bootable live desktop is not yet an installed OS.
