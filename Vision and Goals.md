# Vision and Goals

## Vision

BOLT OS is a customizable, gaming-first Linux distribution. The product is the operating system: a responsive desktop, good gaming support, useful defaults, and control over the machine.

## Primary goals

- Deliver a straightforward, polished graphical desktop.
- Make gaming tools easy to discover and use.
- Keep the default system responsive and avoid unnecessary background services.
- Offer customization without requiring users to rebuild the OS.
- Support a broad range of x86-64 PCs where upstream Linux support allows it.
- Keep OpenCode available as an optional developer tool for people who want it.
- Provide clear documentation and honest compatibility expectations.

## Non-goals

- An AI-first product identity or assistants pushed into every part of the desktop.
- Guaranteeing every game, anti-cheat system, peripheral, or PC configuration works.
- Building a new kernel or graphics driver stack from scratch.
- Claiming benchmark superiority before reproducible testing.
- Requiring an AI provider, account, or cloud connection for the OS to boot, update, or game.

## Product principles

### Gaming first
Prioritize reliable game launching, drivers, Vulkan, controller support, and useful performance diagnostics.

### Purposeful software
Every default package and enabled service should have a clear reason to be there. Avoid unnecessary background agents, duplicate services, pop-ups, and features that users did not ask for.

### OpenCode is optional
Keep OpenCode separate from the core desktop. Users decide whether to install or configure it, which provider to use, and what information to send to that provider.

### Lean, not fragile
Reduce unnecessary background work without removing security updates, networking, audio, power management, accessibility, or other essential services.

### Customizable and maintainable
Prefer upstream packages, documented configuration, and reproducible build steps over opaque one-off modifications.

## Success criteria

- First boot and installation succeed in supported test environments.
- System updates work without breaking the boot path.
- Steam and Vulkan work on tested hardware.
- Idle RAM, boot time, and gaming frame-time behavior are measured against a documented baseline.
- Optional software does not run in the background without a clear need.
