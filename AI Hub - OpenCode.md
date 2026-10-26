# Optional Developer Tool — OpenCode

## Positioning

OpenCode is an optional developer tool for people who want AI-assisted coding and agent workflows. It is not the identity of BOLT OS and should not be pushed into the shell, settings, file manager, or ordinary system applications.

## Principles

- No assistant is required to boot, update, configure, or play games.
- OpenCode is user-launched and easy to ignore or remove.
- The user chooses any supported model provider and decides what code or prompts to share.
- BOLT OS must not send prompts or project files to a provider without explicit user action.
- Clearly distinguish local processing from remote provider processing.
- Do not store credentials in this repository or expose them in logs and diagnostics.

## Setup goals

- Document a currently supported installation method.
- Explain that OpenCode is tooling and needs a supported model provider or a local inference service.
- Provide secure credential guidance.
- Test that removing OpenCode does not affect the desktop or gaming stack.
- Keep provider setup out of the mandatory first-boot flow.

## First prototype

1. Verify OpenCode's official installation and configuration instructions.
2. Document setup as an optional step.
3. Test a supported provider workflow and, if practical, a local workflow.
4. Keep configuration and provider choice under the user's control.

## Open questions

- Should OpenCode be mentioned in the installer, app discovery, or documentation only?
- Which providers should the documentation cover first?
- Should local inference remain community documentation until tested?
