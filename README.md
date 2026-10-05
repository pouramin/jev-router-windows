# Jev Router for Windows

<p align="center">
  <strong>A graphical Windows control panel for connecting TypeSafe Jev to Codex and Claude Code.</strong>
</p>

<p align="center">
  <strong>English</strong>
  &nbsp;|&nbsp;
  <a href="README_FA.md"><strong>فارسی</strong></a>
</p>

<p align="center">
  <img alt="Windows" src="https://img.shields.io/badge/Windows-10%20%2F%2011-0078D4?style=flat-square&logo=windows">
  <img alt="License" src="https://img.shields.io/badge/license-MIT-blue?style=flat-square">
  <img alt="Status" src="https://img.shields.io/badge/status-alpha-f0c35a?style=flat-square">
</p>

## What this project is

**Jev Router for Windows** is a graphical setup and control panel for people who want to use TypeSafe **Jev** with coding-agent workflows on Windows without manually editing config files, managing environment variables, or working in PowerShell.

The current app supports two integrations:

- **Codex Desktop / Codex CLI** — automatic per-turn model and reasoning routing through the open-source `jev-codex-bridge`.
- **Claude Code in Claude Desktop** — automatic installation and removal of the `Jev Model Router` plugin through Claude Code's supported plugin CLI.

The two integrations are intentionally different. Codex uses a transparent bridge/provider path, while Claude uses a plugin-based routing workflow.

## Current Windows UI

The graphical app now includes:

- Maximized startup by default.
- TypeSafe API-key verification.
- DPAPI-protected local key storage.
- **Clear saved key** control.
- One toggle button per integration:
  - **Connect Codex** ↔ **Disconnect Codex**
  - **Connect Claude** ↔ **Disconnect Claude**
- **Open Codex** and **Open Claude** shortcuts.
- Live detection for the Codex app, Jev Bridge, Claude Desktop, and Jev Model Router.
- **Refresh status** and **Reset JEV** controls.
- Direct links to TunnelLab, GitHub, and pouramin.dev in the footer.

## Who it is for

The target user should be able to:

1. Download the portable package.
2. Extract it.
3. Paste a TypeSafe API key.
4. Click **Verify & save**.
5. Connect Codex, Claude, or both.

Normal GUI setup does not require manual terminal work.

## Quick start

### Portable alpha

1. Download the latest Windows ZIP from **Releases**.
2. Extract the archive.
3. Double-click `START_JEV_ROUTER.vbs`.
4. Paste your TypeSafe API key.
5. Click **Verify & save**.
6. Click **Connect Codex** and/or **Connect Claude**.
7. Restart or reopen the target app if the UI asks you to refresh its model/plugin state.

The recommended VBS launcher starts the WPF application without opening a visible PowerShell or CMD window.

## TypeSafe API key

The app verifies the key before saving it.

The primary local copy is protected with Windows **DPAPI** and scoped to the current Windows user.

The GUI also provides:

- **Verify & save** — verifies and stores the current key.
- **Clear saved key** — removes only the DPAPI-protected key stored by Jev Router.
- **Reset JEV** — removes Jev Router integrations and credentials configured by this project.

Clearing the saved key does not automatically tear down an already configured Codex or Claude integration. Use the relevant **Disconnect** action for that.

## Codex integration

When **Connect Codex** is clicked, Jev Router can:

1. Detect Codex, Git, Node.js, and Jev Bridge.
2. Install Git and Node.js 24+ with WinGet when required.
3. Install the upstream `jev-codex-bridge` package.
4. Write the TypeSafe key to the bridge key file with Windows-safe encoding.
5. Restrict access to the bridge credential file where possible.
6. Run the bridge installation with the key-file path explicitly supplied.
7. Back up and update the Codex configuration.
8. Register the bridge background task.
9. Expose **Jev Router** through Codex's model/provider UI.

The upstream bridge reuses the user's existing Codex sign-in. Jev Router does not ask for an OpenAI API key.

### Disconnect Codex

The same Codex button becomes **Disconnect Codex** after the bridge is detected.

Disconnect attempts the upstream restore first. If the original backup cannot be restored safely because the Codex config changed after installation, Jev Router falls back to removing only the Jev-specific provider entries while preserving unrelated config changes.

It then removes:

- the Jev bridge service/task,
- the global bridge package,
- the bridge key file,
- local bridge state.

Restart Codex Desktop after disconnecting so its model list is refreshed.

## Claude Code integration

When **Connect Claude** is clicked, Jev Router:

1. Stores `TYPESAFE_API_KEY` as a Windows user environment variable for plugin compatibility.
2. Detects the Claude Code CLI.
3. Installs the official Claude Code CLI with WinGet when it is missing.
4. Registers this marketplace through Claude Code's supported plugin CLI:

   `Mandrilsquad1441/jev-model-router`

5. Installs this plugin at user scope:

   `jev-model-router@jev-model-router`

6. Opens Claude Desktop.

This remains a **plugin integration**. It is not the same transparent provider bridge used by Codex.

Restart or reload the Claude Code session after the first installation if the plugin does not appear immediately.

### Disconnect Claude

Once the plugin is detected, the same button becomes **Disconnect Claude**.

The disconnect flow attempts to:

- uninstall `jev-model-router@jev-model-router`,
- remove the Jev marketplace entry,
- clear Jev/TypeSafe environment variables created for the Claude integration.

Restart Claude Desktop afterward to refresh plugin state.

## Open-app shortcuts

The UI includes:

- **Open Codex**
- **Open Claude**

The Codex shortcut tries the Codex deep link first and falls back to the web Codex entry point when necessary.

## Status and reset behavior

The footer shows current Windows prerequisites and provides:

- **Refresh status**
- **Reset JEV**

**Reset JEV** attempts to return both integrations to their pre-Jev state and also removes the locally saved DPAPI key.

Use it when you want to remove all configuration created by this project.

## CLI setup

A PowerShell CLI is still included for users who prefer it.

One-line bootstrap:

```powershell
irm https://raw.githubusercontent.com/pouramin/jev-router-windows/main/install.ps1 | iex
```

Then open a new PowerShell window and run:

```powershell
jev-router
```

The CLI can configure Codex, Claude, both integrations, change the TypeSafe key, refresh status, or reset integrations.

## Privacy

A router cannot classify a task without receiving routing context. TypeSafe therefore receives the context required to make the Jev routing decision.

The original coding-agent request is still sent to the selected provider as part of the normal agent workflow.

Exact retention and processing behavior depends on TypeSafe and the upstream integrations. Review their documentation before using sensitive private code.

## Security notes

The app uses several storage mechanisms because the upstream integrations have different requirements:

- Jev Router's primary saved key uses Windows DPAPI.
- Codex Bridge currently requires a local key file.
- Claude plugin compatibility currently uses a user-level environment variable.

Read [SECURITY.md](SECURITY.md) before using the alpha on shared Windows accounts or highly sensitive repositories.

## Project status

This project is currently **alpha**.

Current scope:

- Windows 10 / 11
- Maximized WPF GUI
- Console-free launcher
- TypeSafe key verification
- DPAPI secret storage
- Saved-key removal
- Toggle-based connect/disconnect controls
- Codex Bridge installation and cleanup
- Codex config fallback cleanup on disconnect
- Codex background-service setup
- Automatic Claude Code CLI installation when needed
- Automatic Claude marketplace registration
- Automatic Claude plugin installation and removal
- Open Codex / Open Claude shortcuts
- Integration status detection
- TunnelLab / GitHub / website footer links
- Portable Windows package
- GitHub Actions build, smoke test, and rolling release

Planned work:

- Signed Windows installer
- Stronger Claude plugin-status detection
- In-app decision history and router health
- Update channel for Jev Router itself

## Build from source

The GUI is written in Windows PowerShell + WPF.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\src\JevRouter.ps1
```

For normal portable use, launch:

`START_JEV_ROUTER.vbs`

## Links

- Website: https://pouramin.dev/
- GitHub: https://github.com/pouramin
- TunnelLab: https://www.youtube.com/@tunnellab

## Third-party projects

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

MIT. See [LICENSE](LICENSE).
