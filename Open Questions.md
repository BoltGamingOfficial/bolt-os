# Open Questions

Use this note to make decisions explicit. Record the chosen option, reasoning, date, and consequences.

## First release
- [ ] Is the first prototype for desktop PCs only, or laptops too?
- [ ] What minimum CPU, RAM, and storage should be tested?
- [ ] Should the initial image prioritize a live demo, an installer, or both?
- [ ] What is the release cadence and update policy?

## Base and desktop
- [ ] Confirm Arch Linux as the base.
- [ ] Confirm KDE Plasma as the default desktop.
- [ ] Choose ISO build tooling and pin a reproducible build environment.
- [ ] Decide how Secure Boot will be documented or supported.
- [ ] Decide which services are essential versus optional.

## Gaming
- [ ] Which launchers are default installs versus optional installs?
- [ ] How should users manage Proton-GE?
- [ ] Which overlay and performance tools belong in the default image?
- [ ] What hardware and games form the initial benchmark suite?
- [ ] What graphics driver strategy should be documented for NVIDIA hardware?

## Optional developer tooling
- [x] OpenCode is optional and separate from the core desktop.
- [x] No AI provider or account is required to use the OS.
- [ ] Should OpenCode be mentioned in the installer, app discovery, or documentation only?
- [ ] Which providers should the documentation cover first?
- [ ] Should local inference remain out of scope until tested?

## Branding
- [x] Gold background with a simple black lightning bolt is the initial direction.
- [ ] Choose the exact gold background color.
- [ ] Choose bolt geometry and proportions.
- [ ] Approve logo, wallpaper and boot splash variants.

## Performance and quality
- [x] Define an explicit idle-memory target and test procedure in [[Memory Budget]].
- [ ] Build and boot the first ISO.
- [ ] Capture RAM and boot-time baselines on the same reference hardware.
- [ ] Test Wi-Fi, audio, Vulkan and shutdown in a VM.
- [ ] Test on Intel, AMD and NVIDIA hardware before publishing compatibility claims.

## Project policy
- [ ] Choose a repository license before public distribution.
- [ ] Define how compatibility claims are tested.
- [ ] Define how security updates and urgent regressions are handled.
