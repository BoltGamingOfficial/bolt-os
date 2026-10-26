# BOLT OS Dashboard

> [!abstract] Mission
> Build a customizable, gaming-first Linux OS that feels polished and stays lean, while bringing AI development tools within easy reach.

## Project notes

- [[Vision and Goals|Vision and goals]]
- [[System Architecture|System architecture]]
- [[Gaming Experience|Gaming stack]]
- [[AI Hub - OpenCode|AI integration]]
- [[Hardware Compatibility|Hardware and driver support]]
- [[Branding|Visual identity]]
- [[Roadmap|Roadmap]]
- [[Open Questions|Decisions to make]]

## Principles

1. **Gaming first:** prioritize reliable game launching, drivers, Vulkan, controllers, and performance tools.
2. **Lean by default:** avoid unnecessary background services; let users enable optional features.
3. **User choice:** make desktop appearance and system components configurable.
4. **Honest compatibility:** detect hardware and provide fallbacks, but never promise every device or game will work.
5. **AI with user control:** support configurable providers and protect credentials.
6. **Test before claiming:** validate install media, boot, updates, graphics, and gaming in virtual machines and on real hardware.

## Current status

- [x] Planning notes organized as an Obsidian-friendly vault
- [ ] Choose initial release scope
- [ ] Create reproducible build configuration
- [ ] Build a first bootable ISO
- [ ] Test boot and install in a VM
- [ ] Test Intel, AMD, and NVIDIA graphics paths
- [ ] Establish performance and reliability baselines

## Working rule

Record uncertain decisions in [[Open Questions]] rather than quietly treating assumptions as requirements.
