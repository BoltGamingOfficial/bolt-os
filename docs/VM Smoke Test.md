# BOLT OS VM Smoke Test

This script runs **inside a booted BOLT OS session** and records a diagnostic report. It does not emulate user interaction, prove physical hardware compatibility, or make a CI build into a boot test.

## Run it

After booting the exact ISO artifact and logging into KDE:

```sh
bash /usr/local/share/bolt-os/tests/vm-smoke-test.sh
```

If the test script is not installed in that image, clone/download the repository into the live session and run `bash tests/vm-smoke-test.sh`. The report is written under `~/.local/state/bolt-os/`.

The script records kernel/session details, memory, boot timing, failed units, essential services, Firefox/Steam presence, Vulkan summary when available, process RSS, disk usage, and a settings-persistence sentinel. Review the report and separately test keyboard/mouse, scaling, network reconnect/DNS, audio output/input, launching Firefox and Steam, suspend/resume where supported, reboot, and shutdown.

## Persistence test interpretation

On the current live ISO, the root filesystem and home directory are ephemeral. The sentinel is therefore expected to disappear after a full reboot; that is **not** evidence that an installed BOLT OS should behave the same way. Persistent settings across reboot/shutdown are an installed-system release gate and cannot be honestly marked complete until an installer or persistent-storage design exists and is tested.

Run the script once, reboot or shut down fully, then run it again. Record whether the sentinel remains. Do not claim persistence based only on a successful ISO build.
