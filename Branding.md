# Branding

## Approved direction

- Name: **BOLT OS**
- Motif: a simple geometric lightning bolt
- Default wallpaper: gold background with a black bolt
- Overall feel: bold, clean, minimal, gaming-oriented
- Source asset: `branding/bolt-wallpaper.svg`
- The build script copies the SVG to `/usr/share/wallpapers/BOLT.svg`; the live user's first-session script attempts to apply it once.

## Current implementation status

- [x] Vector wallpaper asset exists.
- [x] Build script includes the wallpaper in the live image.
- [x] First-session setup avoids repeatedly overriding a user's wallpaper choice after the marker is created.
- [ ] Verify wallpaper application in the current ISO after a clean boot.
- [ ] Finalize and verify panel layout and readable desktop defaults.
- [ ] Finalize and verify SDDM login presentation.
- [ ] Add and verify boot splash presentation.
- [ ] Create app icon and any additional assets only after the core mark is approved.
- [ ] Record asset provenance and attribution.

## Visual rules

- Keep the bolt recognizable at small sizes.
- Prefer high contrast and few visual elements.
- Ensure icons and text remain readable on the desktop.
- Test wallpaper readability behind desktop icons and panels.
- Preserve standard KDE settings and user control; do not continually reset user choices on login.

## Release gate

Branding is not considered complete merely because an SVG exists or an ISO builds. Verify the wallpaper, panel, login screen, and boot presentation in the exact ISO artifact and record screenshots or test notes. Do not claim the login or boot splash is customized until that has been implemented and tested.
