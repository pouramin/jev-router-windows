# Jev Router for Windows

[فارسی](README_FA.md) · **English** · [Main page](README.md)

## Overview

**Jev Router for Windows** is a graphical Windows control panel for connecting TypeSafe **Jev** to Codex and Claude Code without manually editing configuration files, managing environment variables, or working in PowerShell.

Current integrations:

- **Codex Desktop / Codex CLI** — automatic per-turn routing through the open-source `jev-codex-bridge`.
- **Claude Code in Claude Desktop** — automatic user-scope installation of the `Jev Model Router` plugin through Claude Code's supported plugin CLI.

Codex uses a transparent bridge/provider workflow. Claude uses a plugin workflow.

## Current GUI

The app currently provides:

- Maximized startup.
- Console-free launch through `START_JEV_ROUTER.vbs`.
- TypeSafe API-key verification.
- Windows DPAPI storage for the primary saved key.
- **Clear saved key**.
- One state-aware button per integration:
  - **Connect Codex** ↔ **Disconnect Codex**
  - **Connect Claude** ↔ **Disconnect Claude**
- **Open Codex**.
- **Open Claude**.
- Live integration detection.
- **Refresh status**.
- **Reset JEV**.
- Footer links to TunnelLab, GitHub, and pouramin.dev.

## Quick start

1. Download the latest Windows ZIP from **Releases**.
2. Extract it.
3. Double-click `START_JEV_ROUTER.vbs`.
4. Paste your TypeSafe API key.
5. Click **Verify & save**.
6. Connect Codex, Claude, or both.
7. Restart or reopen the target application when prompted.

Normal GUI setup does not require manual terminal work.

## TypeSafe key handling

The app verifies the TypeSafe key before saving it.

The primary saved copy uses Windows **DPAPI** and is scoped to the current Windows user.

The GUI provides:

- **Verify & save** — verify and save the key.
- **Clear saved key** — remove only the DPAPI-protected copy saved by Jev Router.
- **Reset JEV** — remove integrations and credentials configured by this project.

If Codex or Claude is already connected, clearing the saved key alone does not automatically disconnect that integration.

## Codex

### Connect Codex

Jev Router can:

1. Detect Codex, Git, Node.js, and Jev Bridge.
2. Install Git and Node.js 24+ with WinGet when needed.
3. Install `jev-codex-bridge`.
4. Create the bridge credential file using Windows-safe encoding.
5. Restrict its ACL where possible.
6. Pass the key-file path explicitly to the bridge installer.
7. Back up and update Codex configuration.
8. Register the bridge background task.
9. Make **Jev Router** available through Codex's model/provider UI.

The upstream bridge reuses the user's existing Codex authentication. No OpenAI API key is requested.

### Disconnect Codex

After installation, the same button changes to **Disconnect Codex**.

The app first attempts the upstream restore flow. If Codex's configuration has changed since installation and a full restore is unsafe, Jev Router removes only Jev-specific provider entries while preserving unrelated changes.

It also removes the bridge service, global package, key file, and local bridge state.

Restart Codex Desktop afterward to refresh its model list.

## Claude Code

### Connect Claude

Jev Router:

1. Sets `TYPESAFE_API_KEY` for the current Windows user.
2. Detects the Claude Code CLI.
3. Installs the official Claude Code CLI with WinGet if needed.
4. Adds the marketplace:

   `Mandrilsquad1441/jev-model-router`

5. Installs:

   `jev-model-router@jev-model-router`

   at user scope.

6. Opens Claude Desktop.

This is a **PLUGIN** integration rather than the transparent bridge used by Codex.

Restart or reload the Claude Code session after first installation if needed.

### Disconnect Claude

When the plugin is detected, the same button changes to **Disconnect Claude**.

The app attempts to uninstall the plugin, remove the marketplace entry, and clear Jev/TypeSafe environment variables created for the integration.

Restart Claude Desktop afterward to refresh plugin state.

## Open-app shortcuts

The GUI includes:

- **Open Codex**
- **Open Claude**

The Codex shortcut tries a local deep link first and falls back to the web Codex entry point when required.

## Reset JEV

**Reset JEV** is the full cleanup action.

It attempts to:

- disconnect Codex,
- restore or clean Codex configuration,
- remove the Codex bridge,
- remove the Claude plugin and marketplace entry where possible,
- clear Jev/TypeSafe environment variables,
- delete the DPAPI-protected TypeSafe key saved by Jev Router.

## CLI

A PowerShell CLI remains available.

Bootstrap:

```powershell
irm https://raw.githubusercontent.com/pouramin/jev-router-windows/main/install.ps1 | iex
```

Then:

```powershell
jev-router
```

The CLI can configure Codex, Claude, both integrations, change the key, refresh status, and reset integrations.

## Privacy

TypeSafe receives the routing context needed to classify a request and choose a route.

The selected provider still receives the original coding-agent request as part of the normal workflow.

Review TypeSafe and upstream integration documentation before using sensitive private code.

## Security

The integrations currently require different credential-storage mechanisms:

- Jev Router primary key: Windows DPAPI.
- Codex Bridge: local key file with restricted ACL where possible.
- Claude plugin: user-level `TYPESAFE_API_KEY` environment variable.

See [SECURITY.md](SECURITY.md).

## Project status

**Alpha**

Current scope includes:

- Windows 10 / 11
- Maximized WPF UI
- Console-free launcher
- TypeSafe verification
- DPAPI key storage
- Saved-key removal
- Connect/disconnect toggle buttons
- Codex Bridge install/remove
- Codex fallback config cleanup
- Codex background task setup
- Automatic Claude Code CLI installation
- Automatic Claude marketplace registration
- Automatic Claude plugin install/remove
- Open Codex / Open Claude
- Status detection
- Footer links
- Portable package
- GitHub Actions build, smoke-test, and release pipeline

Planned:

- Signed Windows installer
- Better Claude plugin status detection
- Router decision history
- Router health UI
- Self-update channel

## Build from source

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\src\JevRouter.ps1
```

Normal portable launch:

`START_JEV_ROUTER.vbs`

## Links

- Website: https://pouramin.dev/
- GitHub: https://github.com/pouramin
- TunnelLab: https://www.youtube.com/@tunnellab

## Third-party projects

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

MIT. See [LICENSE](LICENSE).
