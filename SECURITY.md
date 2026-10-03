# Security

## API keys

The GUI stores the TypeSafe API key locally using Windows DPAPI scoped to the current Windows user.

For Codex automatic routing, `jev-codex-bridge` currently expects a key file such as `~/.jev-router.env`. When Codex is connected, Jev Router for Windows writes `TYPESAFE_API_KEY` there and restricts the file ACL to the signed-in Windows user when possible.

For Claude's plugin integration, the current alpha stores `TYPESAFE_API_KEY` as a user-level Windows environment variable so the plugin can discover it. This is less isolated than DPAPI storage. Do not use this alpha on shared or untrusted Windows accounts.

## Data sent to TypeSafe

Jev routing requires sending routing context to TypeSafe. The exact context differs by integration. Review the upstream router documentation before using this with sensitive repositories.

## Reporting a vulnerability

Please open a GitHub security advisory or contact the repository owner privately. Do not post API keys, bearer tokens, full request dumps, or private source code in public issues.
