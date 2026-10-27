# BOLT Browser

## Status

**Milestone 0.1 — Firefox customization prototype.** This is not a separate browser engine or a Firefox fork. BOLT Browser currently uses the repository's existing Arch Linux `firefox` package and adds a BOLT-branded local start page plus system-wide Firefox enterprise policies.

## Included

- Local BOLT-branded start page with a DuckDuckGo search form and a few gaming/project links.
- Firefox telemetry and Firefox Studies disabled through managed policies.
- Pocket disabled.
- The start page is the default homepage but is **not locked**; users can change their browser preferences.
- No account, extension, background service, or additional browser runtime is introduced.

The search form submits queries to DuckDuckGo. This is an external service; using the page does not make searches anonymous. Firefox's built-in tracking protection and privacy controls remain available.

## Files and integration

- `airootfs/usr/lib/firefox/distribution/policies.json` — Firefox enterprise policies.
- `airootfs/usr/share/bolt-browser/startpage.html` — local start page.
- `tests/check-browser.sh` — static configuration checks.

The existing `build.sh` copies the `airootfs/` overlay into the Archiso profile, so these files are included without changing the ISO build pipeline or adding packages.

## Validate

From the repository root:

```sh
bash tests/check-browser.sh
python3 -m json.tool airootfs/usr/lib/firefox/distribution/policies.json >/dev/null
```

On a built live ISO, launch Firefox and verify:

1. The BOLT Browser start page appears on startup/new tabs as supported by the installed Firefox version and policy.
2. Search submits to DuckDuckGo and the quick links open.
3. Open `about:policies` and confirm the policies are active without errors.
4. Open Firefox settings and confirm the homepage can be changed.
5. Confirm Firefox tracking protection remains available and the browser works with ordinary websites, video playback, and downloads.

Static checks do not prove the ISO boots or that browser behavior has been tested. Record those results separately.

## Next milestone

Test on the exact BOLT ISO, then decide whether a packaged Firefox distribution/theme and application icon are worthwhile. Avoid maintaining a Firefox fork unless upstream customization proves insufficient.
