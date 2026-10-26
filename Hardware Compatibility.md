# Hardware Compatibility

## Principle

Aim for broad compatibility by using upstream Linux support, reliable detection, and clear fallbacks. Do not promise universal support: vendors, firmware, kernel versions, proprietary drivers, laptop hybrid graphics, and individual games all impose limits.

## Initial target

- x86-64 desktop and laptop PCs.
- UEFI systems as the primary test target.
- Intel and AMD integrated/discrete graphics through supported kernel and Mesa stacks.
- NVIDIA basic desktop and Vulkan fallback paths through Nouveau where supported; proprietary NVIDIA drivers remain a separate path to validate.
- Common wired and Bluetooth input devices, audio devices, Wi-Fi and Ethernet adapters supported by the chosen kernel and firmware.

## Graphics strategy

### Intel and AMD

The initial prototype includes Mesa, Intel/AMD Vulkan drivers, and the corresponding 32-bit Vulkan libraries for common gaming workflows. These packages still need to be exercised on real hardware.

### NVIDIA

The prototype includes the open-source Nouveau Vulkan driver path, including 32-bit libraries for compatible cards. That does not guarantee good performance on every NVIDIA GPU. A proprietary NVIDIA driver choice must match the GPU generation and kernel packaging; test Secure Boot and laptop hybrid-graphics behavior separately.

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
- **Expected:** likely to work through upstream support, but not yet tested.
- **Known issue:** limitation is documented with a workaround if available.
- **Unsupported:** known blocker or outside the project's declared scope.

Keep a hardware test log with model, kernel, driver version, test date, and result.
