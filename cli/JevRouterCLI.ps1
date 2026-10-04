#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Resolve-CoreModule {
    $candidates = @(
        (Join-Path $PSScriptRoot '..\src\RouterCore.psm1'),
        (Join-Path $PSScriptRoot 'RouterCore.psm1'),
        (Join-Path $env:LOCALAPPDATA 'JevRouterForWindows\cli\RouterCore.psm1')
    )
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path -LiteralPath $candidate)) {
            return (Resolve-Path $candidate).Path
        }
    }
    throw 'RouterCore.psm1 was not found. Reinstall Jev Router CLI.'
}

Import-Module (Resolve-CoreModule) -Force
Initialize-JevRouterStorage

function Write-Title {
    Clear-Host
    Write-Host ''
    Write-Host '  JEV ROUTER FOR WINDOWS' -ForegroundColor Yellow
    Write-Host '  TypeSafe Jev setup for Codex and Claude' -ForegroundColor Gray
    Write-Host '  ------------------------------------------------------------' -ForegroundColor DarkGray
    Write-Host ''
}

function Pause-Jev {
    Write-Host ''
    Read-Host 'Press Enter to continue' | Out-Null
}

function Read-PlainFromSecure {
    param([Parameter(Mandatory)][Security.SecureString]$Secure)
    $ptr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($Secure)
    try {
        return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($ptr)
    } finally {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($ptr)
    }
}

function Ensure-TypeSafeKey {
    $saved = Get-SavedTypeSafeKey
    if ($saved) {
        Write-Host 'A protected TypeSafe key is already saved.' -ForegroundColor Green
        $reuse = Read-Host 'Use the saved key? [Y/n]'
        if ([string]::IsNullOrWhiteSpace($reuse) -or $reuse.Trim().ToLowerInvariant() -eq 'y') {
            return $saved
        }
    }

    while ($true) {
        Write-Host ''
        Write-Host 'Paste your TypeSafe API key. Input is hidden.' -ForegroundColor Cyan
        $secure = Read-Host 'API key' -AsSecureString
        $plain = Read-PlainFromSecure -Secure $secure
        if ([string]::IsNullOrWhiteSpace($plain)) {
            Write-Host 'The key was empty.' -ForegroundColor Red
            continue
        }

        Write-Host 'Checking the key with TypeSafe...' -ForegroundColor DarkGray
        $test = Test-TypeSafeApiKey -ApiKey $plain
        if (-not $test.Success) {
            Write-Host ('Verification failed: ' + $test.Message) -ForegroundColor Red
            continue
        }

        Save-TypeSafeKey -ApiKey $plain
        $paths = Get-JevRouterPaths
        Write-Host ''
        Write-Host 'Saved successfully.' -ForegroundColor Green
        Write-Host ('Protected file: ' + $paths.SecretFile) -ForegroundColor Gray
        Write-Host 'Protection: Windows DPAPI / CurrentUser' -ForegroundColor Gray
        return $plain
    }
}

function Show-Status {
    $s = Get-SystemStatus
    $paths = Get-JevRouterPaths
    Write-Host ''
    Write-Host 'Status' -ForegroundColor Cyan
    Write-Host ('  TypeSafe key : ' + $(if($s.KeySaved){'saved'}else{'not saved'}))
    Write-Host ('  Codex        : ' + $(if($s.Codex){'detected'}else{'not detected'}))
    Write-Host ('  Jev Bridge   : ' + $(if($s.CodexBridge){'installed'}else{'not installed'}))
    Write-Host ('  Claude       : ' + $(if($s.ClaudeDesktop){'detected'}else{'not detected'}))
    Write-Host ('  Claude plugin: ' + $(if($s.ClaudePlugin){'detected'}else{'not detected'}))
    Write-Host ('  Node.js      : ' + $s.NodeMajor)
    Write-Host ('  Protected key: ' + $paths.SecretFile) -ForegroundColor DarkGray
}

function Setup-Codex {
    $key = Get-SavedTypeSafeKey
    if (-not $key) { $key = Ensure-TypeSafeKey }

    Write-Host ''
    Write-Host 'Configuring Codex...' -ForegroundColor Cyan
    Write-Host 'This can install Git/Node.js with WinGet, install Jev Codex Bridge, back up Codex config, and register a background task.' -ForegroundColor DarkGray
    $go = Read-Host 'Continue? [Y/n]'
    if ($go -and $go.Trim().ToLowerInvariant() -ne 'y') { return }

    foreach ($line in (Install-CodexBridge -ApiKey $key)) {
        if ($line) { Write-Host $line -ForegroundColor DarkGray }
    }

    Write-Host ''
    Write-Host 'Codex is configured.' -ForegroundColor Green
    Write-Host 'Restart Codex Desktop and select "Jev Router" from the model picker.' -ForegroundColor Gray
}

function Setup-Claude {
    $key = Get-SavedTypeSafeKey
    if (-not $key) { $key = Ensure-TypeSafeKey }

    Write-Host ''
    Write-Host 'Preparing Claude Code / Claude Desktop...' -ForegroundColor Cyan
    $result = Prepare-ClaudeIntegration -ApiKey $key

    Write-Host 'TypeSafe key was added to your Windows user environment for the plugin.' -ForegroundColor Green
    Write-Host ('Marketplace copied to clipboard: ' + $result.Marketplace) -ForegroundColor Gray
    Write-Host ''
    Write-Host 'One Claude security confirmation is still required:' -ForegroundColor Yellow
    Write-Host '  1. Claude Desktop opens to Code.' -ForegroundColor Gray
    Write-Host '  2. Open Customize > Plugins > Add > Add marketplace.' -ForegroundColor Gray
    Write-Host '  3. Paste the copied marketplace and add Jev Model Router.' -ForegroundColor Gray
    Write-Host '  4. Restart the Code session.' -ForegroundColor Gray
    Write-Host ''
    Read-Host 'After you add the plugin in Claude, press Enter here to verify it' | Out-Null

    $status = Get-SystemStatus
    if ($status.ClaudePlugin) {
        Write-Host 'Claude is configured. The plugin is now detected locally.' -ForegroundColor Green
        Write-Host 'It will be available in Claude Code sessions using this Claude account.' -ForegroundColor Green
    } else {
        Write-Host 'The plugin is not detected yet.' -ForegroundColor Yellow
        Write-Host 'You can finish the install later from Claude > Customize > Plugins. The TypeSafe key preparation is already saved.' -ForegroundColor Gray
    }
}

function Reset-Codex {
    Write-Host ''
    $go = Read-Host 'Restore Codex defaults and remove Jev Codex Bridge? [y/N]'
    if ($go.Trim().ToLowerInvariant() -ne 'y') { return }
    foreach ($line in (Remove-CodexBridge)) {
        if ($line) { Write-Host $line -ForegroundColor DarkGray }
    }
    Write-Host 'Codex reset finished.' -ForegroundColor Green
}

function Reset-Claude {
    Write-Host ''
    $go = Read-Host 'Remove Jev/TypeSafe environment keys used by the Claude integration? [y/N]'
    if ($go.Trim().ToLowerInvariant() -ne 'y') { return }
    Remove-ClaudeIntegration
    Write-Host 'Claude Jev environment keys were removed.' -ForegroundColor Green
    Write-Host 'If you added the plugin to your Claude account, remove it from Customize > Plugins to remove the plugin itself.' -ForegroundColor Yellow
}

function Reset-All {
    Write-Host ''
    Write-Host 'This restores Codex defaults where a bridge backup exists and removes Jev/TypeSafe credentials saved by this project.' -ForegroundColor Yellow
    $go = Read-Host 'Reset everything? [y/N]'
    if ($go.Trim().ToLowerInvariant() -ne 'y') { return }
    foreach ($line in (Reset-JevRouterAll)) {
        if ($line) { Write-Host ('  ' + $line) -ForegroundColor DarkGray }
    }
    Write-Host ''
    Write-Host 'Reset complete.' -ForegroundColor Green
    Write-Host 'Claude account plugins are account-level; remove Jev Model Router from Customize > Plugins if you want the plugin itself removed too.' -ForegroundColor Yellow
}

Write-Title
[void](Ensure-TypeSafeKey)

while ($true) {
    Write-Title
    Show-Status
    Write-Host ''
    Write-Host 'What do you want to configure?' -ForegroundColor White
    Write-Host '  1 - ChatGPT / Codex Desktop (Codex routing)'
    Write-Host '  2 - Claude / Claude Code'
    Write-Host '  3 - Both'
    Write-Host '  4 - Change TypeSafe API key'
    Write-Host '  5 - Refresh status'
    Write-Host ''
    Write-Host 'Reset / restore defaults' -ForegroundColor DarkYellow
    Write-Host '  6 - Reset Codex'
    Write-Host '  7 - Reset Claude'
    Write-Host '  8 - Reset everything'
    Write-Host '  0 - Exit'
    Write-Host ''

    $choice = (Read-Host 'Choose').Trim()
    try {
        switch ($choice) {
            '1' { Setup-Codex; Pause-Jev }
            '2' { Setup-Claude; Pause-Jev }
            '3' { Setup-Codex; Setup-Claude; Pause-Jev }
            '4' { Remove-SavedTypeSafeKey; [void](Ensure-TypeSafeKey); Pause-Jev }
            '5' { Pause-Jev }
            '6' { Reset-Codex; Pause-Jev }
            '7' { Reset-Claude; Pause-Jev }
            '8' { Reset-All; Pause-Jev }
            '0' { break }
            default { Write-Host 'Unknown option.' -ForegroundColor Red; Start-Sleep -Milliseconds 700 }
        }
    } catch {
        Write-Host ''
        Write-Host ('Error: ' + $_.Exception.Message) -ForegroundColor Red
        Pause-Jev
    }

    if ($choice -eq '0') { break }
}
