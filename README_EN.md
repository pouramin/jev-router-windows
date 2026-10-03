# Jev Router for Windows

[فارسی](README_FA.md) · **English** · [Main page](README.md)

## What this project is

**Jev Router for Windows** is a graphical setup and control panel aimed at people who want to use TypeSafe **Jev** with coding agents on Windows without manually editing configuration files or living in PowerShell.

The project focuses on two Windows workflows:

- **Codex Desktop / Codex CLI** — automatic per-turn model and reasoning routing through the open-source `jev-codex-bridge` project.
- **Claude Code in Claude Desktop** — guided graphical setup for the `Jev Model Router` plugin. This is an assisted plugin integration, not the same transparent proxy used by Codex in this alpha.

That distinction is intentional. The UI tells the user exactly which integration is automatic and which one is plugin-assisted.

## Who it is for

The target user is someone who can download an app, paste a TypeSafe API key, and click a button — not someone who wants to maintain Node.js packages and configuration files by hand.

## Quick start

### Portable alpha

1. Download the latest Windows package from **Releases**.
2. Extract it.
3. Double-click `START_JEV_ROUTER.bat`.
4. Paste your TypeSafe API key.
5. Click **Verify & save**.
6. Choose **Connect Codex** or **Prepare Claude**.

No terminal interaction is required for normal setup. Some third-party prerequisites may be installed in the background through WinGet after the user confirms.

## Codex integration

The Codex path is the most automated path in the current alpha.

When you click **Connect Codex**, the app can:

1. Detect Git, Node.js, Codex, and the Jev bridge.
2. Install Git and Node.js 24+ with WinGet when required.
3. Install `ansidium/jev-codex-bridge` from its public GitHub repository.
4. Store the TypeSafe key in the key file required by the bridge and restrict its Windows ACL.
5. Run `jev-bridge install`, which backs up and configures Codex.
6. Register the bridge's background Windows task.
7. Leave Codex ready to use the **Jev Router** model/provider after the app is restarted.

The upstream bridge reuses the user's existing Codex authentication; this project does not ask for an OpenAI API key.

## Claude Code integration

Claude Desktop exposes Claude Code in its graphical **Code** experience and supports plugins across the desktop app and Claude Code.

In the current alpha, **Prepare Claude**:

1. Saves `TYPESAFE_API_KEY` as a user-level Windows environment variable for plugin discovery.
2. Copies this marketplace identifier to the clipboard:

   `Mandrilsquad1441/jev-model-router`

3. Opens Claude Desktop's Code area.
4. Shows the exact graphical path:

   **Customize → Plugins → Add → Add marketplace → paste → install Jev Model Router**

This is deliberately labeled **PLUGIN** rather than **AUTOMATIC** in the UI. `Jev Model Router` can recommend and delegate to models, but this alpha does not claim that Claude Desktop is transparently proxy-routed on every turn in the same way as Codex.

## TypeSafe key handling

The key entered into the app is saved with Windows **DPAPI**, scoped to the current Windows user.

Two integrations currently require less isolated compatibility storage:

- Codex Bridge uses `~/.jev-router.env` because the upstream bridge expects a key file. The app tries to restrict that file to the signed-in Windows account.
- Claude plugin compatibility uses a user-level `TYPESAFE_API_KEY` environment variable in this alpha.

Read [SECURITY.md](SECURITY.md) before using the alpha on a shared PC or with sensitive repositories.

## Privacy

A router cannot classify a task without receiving routing context. TypeSafe therefore receives text needed to make the Jev decision. The provider still receives the original coding-agent request as usual.

The exact context and retention behavior depends on TypeSafe and the upstream integration. Review their documentation before using private code.

## Project status

This is an **alpha** Windows usability layer. The project intentionally relies on upstream open-source integrations rather than pretending to own their protocol compatibility.

Current scope:

- Windows 10 / 11
- TypeSafe API key verification
- Local DPAPI secret storage
- One-click-ish Codex Bridge installation and removal
- Codex background-service setup
- Claude Desktop plugin setup assistance
- Detection/status UI
- Portable package
- GitHub Actions release packaging

Planned work:

- Signed Windows installer
- Better Claude plugin status detection
- A fully supported Claude automatic-routing path if/when a stable desktop extension point can safely change the active model per turn
- In-app decision history and router health
- Update channel for this control panel itself

## Build from source

The portable UI is written in Windows PowerShell + WPF so a clean Windows machine can launch it without a separate application runtime.

```powershell
powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\src\JevRouter.ps1
```

The launcher starts the WPF interface through Windows PowerShell in the background, so normal users do not need to open a terminal.

## Third-party projects

See [THIRD_PARTY_NOTICES.md](THIRD_PARTY_NOTICES.md).

## License

MIT. See [LICENSE](LICENSE).
