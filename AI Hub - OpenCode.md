# AI Hub - OpenCode

## Purpose

Provide an optional, discoverable place to launch and configure OpenCode for AI-assisted coding and agent workflows.

**Important distinction:** OpenCode is an agent/tooling application, not a model by itself. It needs a supported model provider or local inference service configured by the user.

## Desired capabilities

- A desktop launcher and setup guide.
- Provider/model configuration based on OpenCode's supported options.
- Clear indication of whether a provider is local or remote.
- Guidance for setting up API credentials securely.
- Optional local-model workflows where hardware and supported runtimes permit.
- Easy disable/uninstall path; the OS must remain usable without AI.
- Diagnostics that do not print secret values.

## Credential safety

- Never commit API keys, access tokens, or personal configuration.
- Prefer documented secret storage or environment/config mechanisms supported by the provider.
- Ensure logs and support bundles redact credentials.
- Explain that remote providers may process prompts and code off-device according to their own terms.
- Make provider choice and data handling visible to the user.

## First prototype

1. Verify the supported OpenCode installation method and current configuration format.
2. Package or document installation without bundling secrets.
3. Add a launcher and first-run checklist.
4. Test with one remote provider and one local workflow if feasible.
5. Confirm the AI hub can be removed without affecting the desktop or gaming stack.

## Questions

- Should the AI hub be a simple launcher/settings page first, or a custom graphical application?
- Which providers should be documented in the first release?
- Should local inference be a supported target for the first prototype, or a later optional feature?
