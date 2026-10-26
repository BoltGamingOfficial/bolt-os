# Hardware Compatibility

## Principle

Aim for broad compatibility by using upstream Linux support, reliable detection, and clear fallbacks. Do not promise universal support: hardware vendors, firmware, kernel versions, proprietary drivers, laptop hybrid graphics, and individual games all impose limits.

## Initial target

- x86-64 desktop and laptop PCs.
- UEFI systems as the primary test target.
- Intel and AMD integrated/discrete graphics through supported kernel and Mesa stacks.
- NVIDIA graphics through a documented driver-selection path.
- Common wired and Bluetooth input devices, audio devices, Wi-Fi and Ethernet adapters supported by the selected kernel/firmware packages.

## Graphics strategy

### Intel and AMD
Validate kernel drivers, Mesa, Vulkan loader, and 32-bit graphics libraries needed by relevant gaming workflows.

### NVIDIA
Choose a driver strategy based on supported GPUs, kernel updates, and the current Arch packaging landscape. Document secure boot and hybrid graphics implications where relevant. Do not assume one driver branch supports every NVIDIA GPU.

### Fallbacks
If hardware acceleration is unavailable, show a useful diagnostic and allow a safe desktop fallback where possible. Avoid silently presenting software rendering as normal gaming performance.

## Compatibility checklist

- [ ] CPU architecture and virtualization features
- [ ] GPU model and loaded driver
- [ ] Vulkan device and 32-bit library checks
- [ ] Wi-Fi, Bluetooth, Ethernet
- [ ] Audio input/output
- [ ] Suspend/resume and laptop power management
- [ ] External displays and mixed-DPI scaling
- [ ] UEFI boot and Secure Boot implications
- [ ] Controller and common peripheral input
- [ ] Recovery path after failed graphics or kernel update

## Support tiers to define

- **Tested:** verified on a named hardware configuration and release.
- **Expected:** likely to work through upstream support, but not yet tested by the project.
- **Known issue:** limitation is documented with a workaround if available.
- **Unsupported:** known blocker or outside the project's declared scope.

Keep a hardware test log with model, kernel, driver version, test date, and result.
