# Vision and Goals

## Vision

BOLT OS should be a modern, customizable Linux distribution built around PC gaming, with a clean desktop and an integrated AI tool hub.

## Primary goals

- Deliver a straightforward graphical desktop.
- Make common gaming tools easy to discover and use.
- Keep the default system responsive and avoid unnecessary services.
- Offer customization without requiring users to rebuild the operating system.
- Support a broad range of x86-64 PCs and graphics hardware where upstream Linux drivers allow it.
- Integrate OpenCode as an optional AI coding/agent workflow with user-selected model providers.
- Provide clear documentation and realistic compatibility expectations.

## Non-goals for the first prototype

- Guaranteeing every game, anti-cheat system, peripheral, or PC configuration works.
- Building a new Linux kernel or graphics driver stack from scratch.
- Claiming benchmark superiority before reproducible testing.
- Requiring cloud AI or a paid AI provider for the OS to boot and function.

## Product principles

### Gaming without guesswork
Offer useful defaults and diagnostic information, while documenting where compatibility depends on the game, Proton version, driver, firmware, or anti-cheat policy.

### Lean, not stripped to the point of fragility
Reduce optional background work, but retain security updates, networking, audio, power management, accessibility, and other essential services.

### Customizable
Provide settings or selectable profiles for desktop effects, optional apps, AI providers, and gaming utilities.

### Open and maintainable
Prefer upstream packages and reproducible build steps over opaque one-off modifications.

## Success criteria to define

- First boot and installation succeed in supported test environments.
- System updates work without breaking the boot path.
- Steam and Vulkan work on tested hardware.
- Idle RAM, boot time, and gaming frame-time behavior are measured against a documented baseline.
- AI features can be disabled and do not block core OS functionality.
