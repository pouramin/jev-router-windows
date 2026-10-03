# Architecture

Jev Router for Windows is a usability layer, not a new routing model.

## Codex

`GUI → verify TypeSafe key → install prerequisites if needed → install jev-codex-bridge → configure Codex → Windows background task → TypeSafe Jev → selected Codex model/effort`

The bridge remains the component responsible for protocol interception and model rewriting.

## Claude Code Desktop

`GUI → verify TypeSafe key → set compatibility environment → open Claude Desktop → user installs Jev Model Router plugin from graphical Plugins UI → plugin can recommend/delegate model choices`

The current alpha does not claim transparent Claude per-turn proxy routing.

## Secret boundaries

The control panel keeps its own copy of the TypeSafe key in DPAPI-protected storage. Compatibility copies are only created when a user explicitly connects an integration.
