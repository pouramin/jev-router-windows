Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$script:AppName = 'Jev Router for Windows'

$appDataRoot = $env:LOCALAPPDATA
if ([string]::IsNullOrWhiteSpace($appDataRoot)) {
    $appDataRoot = [Environment]::GetFolderPath([Environment+SpecialFolder]::LocalApplicationData)
}
if ([string]::IsNullOrWhiteSpace($appDataRoot)) {
    throw 'Windows LocalApplicationData path is unavailable.'
}

$userHome = $HOME
if ([string]::IsNullOrWhiteSpace($userHome)) {
    $userHome = [Environment]::GetFolderPath([Environment+SpecialFolder]::UserProfile)
}
if ([string]::IsNullOrWhiteSpace($userHome)) {
    throw 'Windows user profile path is unavailable.'
}

$script:AppDataDir = Join-Path $appDataRoot 'JevRouterForWindows'
$script:SecretFile = Join-Path $script:AppDataDir 'typesafe.key'
$script:LogFile = Join-Path $script:AppDataDir 'app.log'
$script:BridgeEnvFile = Join-Path $userHome '.jev-router.env'

function Initialize-JevRouterStorage {
    New-Item -ItemType Directory -Path $script:AppDataDir -Force | Out-Null
}

function Write-JevRouterLog {
    param([Parameter(Mandatory)][string]$Message)
    Initialize-JevRouterStorage
    $line = "[{0}] {1}" -f (Get-Date -Format 'yyyy-MM-dd HH:mm:ss'), $Message
    Add-Content -Path $script:LogFile -Value $line -Encoding UTF8
}

function Protect-TextForCurrentUser {
    param([Parameter(Mandatory)][string]$Text)
    Add-Type -AssemblyName System.Security
    $bytes = [Text.Encoding]::UTF8.GetBytes($Text)
    $protected = [Security.Cryptography.ProtectedData]::Protect(
        $bytes,
        $null,
        [Security.Cryptography.DataProtectionScope]::CurrentUser
    )
    return [Convert]::ToBase64String($protected)
}

function Unprotect-TextForCurrentUser {
    param([Parameter(Mandatory)][string]$ProtectedText)
    Add-Type -AssemblyName System.Security
    $bytes = [Convert]::FromBase64String($ProtectedText)
    $plain = [Security.Cryptography.ProtectedData]::Unprotect(
        $bytes,
        $null,
        [Security.Cryptography.DataProtectionScope]::CurrentUser
    )
    return [Text.Encoding]::UTF8.GetString($plain)
}

function Save-TypeSafeKey {
    param([Parameter(Mandatory)][string]$ApiKey)
    if ([string]::IsNullOrWhiteSpace($ApiKey)) { throw 'TypeSafe API key is empty.' }
    Initialize-JevRouterStorage
    $protected = Protect-TextForCurrentUser -Text $ApiKey.Trim()
    Set-Content -Path $script:SecretFile -Value $protected -Encoding ASCII
    Write-JevRouterLog 'Saved TypeSafe API key with Windows DPAPI (CurrentUser).'
}

function Get-SavedTypeSafeKey {
    if (-not (Test-Path $script:SecretFile)) { return $null }
    try {
        $protected = (Get-Content $script:SecretFile -Raw).Trim()
        if ([string]::IsNullOrWhiteSpace($protected)) { return $null }
        return Unprotect-TextForCurrentUser -ProtectedText $protected
    } catch {
        Write-JevRouterLog "Could not decrypt saved key: $($_.Exception.Message)"
        return $null
    }
}

function Remove-SavedTypeSafeKey {
    if (Test-Path $script:SecretFile) { Remove-Item $script:SecretFile -Force }
}


function Get-JevRouterPaths {
    return [pscustomobject]@{
        AppDataDir = $script:AppDataDir
        SecretFile = $script:SecretFile
        LogFile = $script:LogFile
        BridgeEnvFile = $script:BridgeEnvFile
    }
}

function Remove-CodexBridgeKeyFile {
    if (-not (Test-Path $script:BridgeEnvFile)) { return }

    $remaining = Get-Content $script:BridgeEnvFile -ErrorAction SilentlyContinue |
        Where-Object { $_ -notmatch '^\s*(TYPESAFE_API_KEY|JEV_API_KEY|JEV_ROUTER_TYPESAFE_API_KEY)\s*=' }

    if (@($remaining).Count -eq 0) {
        Remove-Item $script:BridgeEnvFile -Force -ErrorAction SilentlyContinue
    } else {
        Set-Content -Path $script:BridgeEnvFile -Value $remaining -Encoding UTF8
        Set-RestrictedFileAcl -Path $script:BridgeEnvFile
    }

    Write-JevRouterLog 'Removed Jev/TypeSafe keys from the Codex bridge environment file.'
}

function Test-TypeSafeApiKey {
    param([Parameter(Mandatory)][string]$ApiKey)
    try {
        $headers = @{ Authorization = "Bearer $($ApiKey.Trim())" }
        $response = Invoke-RestMethod -Uri 'https://api.typesafe.ai/v1/models' -Headers $headers -Method Get -TimeoutSec 15
        $names = @()
        if ($response.models) { $names = @($response.models | ForEach-Object { $_.name }) }
        return [pscustomobject]@{ Success = $true; Message = 'Connected to TypeSafe'; Models = $names }
    } catch {
        $msg = $_.Exception.Message
        if ($_.ErrorDetails -and $_.ErrorDetails.Message) { $msg = $_.ErrorDetails.Message }
        return [pscustomobject]@{ Success = $false; Message = $msg; Models = @() }
    }
}

function Refresh-ProcessPath {
    $machine = [Environment]::GetEnvironmentVariable('Path', 'Machine')
    $user = [Environment]::GetEnvironmentVariable('Path', 'User')
    $env:Path = (($machine, $user) -join ';')
}

function Get-CommandPathSafe {
    param([Parameter(Mandatory)][string]$Name)
    try {
        $cmd = Get-Command $Name -ErrorAction Stop
        return $cmd.Source
    } catch { return $null }
}

function Get-NodeMajorVersion {
    $node = Get-CommandPathSafe -Name 'node'
    if (-not $node) { return 0 }
    try {
        $raw = (& $node --version 2>$null).Trim().TrimStart('v')
        return [int]($raw.Split('.')[0])
    } catch { return 0 }
}

function Get-ClaudeCodeCliPath {
    Refresh-ProcessPath

    foreach ($name in @('claude.exe','claude')) {
        $path = Get-CommandPathSafe -Name $name
        if ($path) { return $path }
    }

    $native = Join-Path $userHome '.local\bin\claude.exe'
    if (Test-Path -LiteralPath $native) {
        $nativeDir = Split-Path -Parent $native
        if (($env:Path -split ';') -notcontains $nativeDir) {
            $env:Path = $nativeDir + ';' + $env:Path
        }
        return $native
    }

    return $null
}

function Ensure-ClaudeCodeCli {
    $messages = New-Object System.Collections.Generic.List[string]
    $claude = Get-ClaudeCodeCliPath
    if ($claude) {
        return [pscustomobject]@{ Path = $claude; Messages = $messages }
    }

    $messages.Add('Installing Claude Code CLI with WinGet…')
    [void](Install-WithWinget -PackageId 'Anthropic.ClaudeCode')
    Refresh-ProcessPath

    $nativeDir = Join-Path $userHome '.local\bin'
    if (Test-Path -LiteralPath $nativeDir) {
        if (($env:Path -split ';') -notcontains $nativeDir) {
            $env:Path = $nativeDir + ';' + $env:Path
        }
    }

    $claude = Get-ClaudeCodeCliPath
    if (-not $claude) {
        throw 'Claude Code CLI was installed but the claude command is still unavailable. Close and reopen Jev Router, then try Connect Claude again.'
    }

    return [pscustomobject]@{ Path = $claude; Messages = $messages }
}

function Test-ClaudeDesktopInstalled {
    $candidates = @(
        (Join-Path $env:LOCALAPPDATA 'AnthropicClaude\Claude.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Claude\Claude.exe'),
        (Join-Path $env:ProgramFiles 'Claude\Claude.exe')
    )
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) { return $true }
    }
    try {
        if (Get-AppxPackage -Name '*Claude*' -ErrorAction SilentlyContinue) { return $true }
    } catch { }
    try {
        $handler = Get-ItemProperty 'Registry::HKEY_CURRENT_USER\Software\Classes\claude\shell\open\command' -ErrorAction SilentlyContinue
        if ($handler) { return $true }
    } catch { }
    return $false
}

function Test-CodexInstalled {
    if (Get-CommandPathSafe -Name 'codex') { return $true }
    try {
        if (Get-AppxPackage -Name '*Codex*' -ErrorAction SilentlyContinue) { return $true }
        if (Get-AppxPackage -Name '*ChatGPT*' -ErrorAction SilentlyContinue) { return $true }
    } catch { }
    $paths = @(
        (Join-Path $env:LOCALAPPDATA 'Programs\Codex\Codex.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\ChatGPT\ChatGPT.exe')
    )
    return [bool]($paths | Where-Object { Test-Path $_ } | Select-Object -First 1)
}

function Test-ClaudePluginPresent {
    $claude = Get-ClaudeCodeCliPath
    if ($claude) {
        try {
            $list = Invoke-ProcessCaptured -FilePath $claude -ArgumentList @('plugin','list') -TimeoutSeconds 60
            if ($list -match 'jev-model-router@jev-model-router') { return $true }
        } catch { }
    }

    $installed = Join-Path $userHome '.claude\plugins\installed_plugins.json'
    if (Test-Path -LiteralPath $installed) {
        try {
            $json = Get-Content -LiteralPath $installed -Raw | ConvertFrom-Json
            if ($json.plugins -and $json.plugins.PSObject.Properties.Name -contains 'jev-model-router@jev-model-router') {
                return $true
            }
        } catch { }
    }

    return $false
}

function Test-CodexBridgePresent {
    Refresh-ProcessPath
    $bridge = Get-CommandPathSafe -Name 'jev-bridge.cmd'
    if (-not $bridge) { $bridge = Get-CommandPathSafe -Name 'jev-bridge' }
    if (-not $bridge) { return $false }

    $state = Join-Path $userHome '.config\jev-codex-bridge\state.json'
    return (Test-Path -LiteralPath $state)
}

function Get-SystemStatus {
    Refresh-ProcessPath
    return [pscustomobject]@{
        ClaudeDesktop = Test-ClaudeDesktopInstalled
        ClaudeCodeCommand = [bool](Get-ClaudeCodeCliPath)
        ClaudePlugin = Test-ClaudePluginPresent
        Codex = Test-CodexInstalled
        CodexCommand = [bool](Get-CommandPathSafe -Name 'codex')
        CodexBridge = Test-CodexBridgePresent
        NodeMajor = Get-NodeMajorVersion
        Git = [bool](Get-CommandPathSafe -Name 'git')
        Winget = [bool](Get-CommandPathSafe -Name 'winget')
        KeySaved = [bool](Get-SavedTypeSafeKey)
    }
}

function ConvertTo-ProcessArgumentString {
    param([string[]]$Arguments = @())
    $quoted = foreach ($arg in $Arguments) {
        if ($null -eq $arg) { '""'; continue }
        $value = [string]$arg
        if ($value -notmatch '[\s"]') { $value; continue }
        $escaped = $value -replace '(\\*)"', '$1$1\"'
        $escaped = $escaped -replace '(\\+)$', '$1$1'
        '"' + $escaped + '"'
    }
    return ($quoted -join ' ')
}

function Invoke-ProcessCaptured {
    param(
        [Parameter(Mandatory)][string]$FilePath,
        [string[]]$ArgumentList = @(),
        [int]$TimeoutSeconds = 600
    )
    $psi = New-Object System.Diagnostics.ProcessStartInfo
    $psi.FileName = $FilePath
    $psi.Arguments = ConvertTo-ProcessArgumentString -Arguments $ArgumentList
    $psi.UseShellExecute = $false
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $psi.CreateNoWindow = $true
    $p = New-Object System.Diagnostics.Process
    $p.StartInfo = $psi
    [void]$p.Start()
    if (-not $p.WaitForExit($TimeoutSeconds * 1000)) {
        try { $p.Kill() } catch { }
        throw "Timed out: $FilePath $($ArgumentList -join ' ')"
    }
    $stdout = $p.StandardOutput.ReadToEnd().Trim()
    $stderr = $p.StandardError.ReadToEnd().Trim()
    $combined = (($stdout, $stderr) | Where-Object { $_ }) -join [Environment]::NewLine
    if ($p.ExitCode -ne 0) {
        throw "Command failed ($($p.ExitCode)): $FilePath $($ArgumentList -join ' ')`n$combined"
    }
    return $combined
}

function Install-WithWinget {
    param([Parameter(Mandatory)][string]$PackageId)
    $winget = Get-CommandPathSafe -Name 'winget'
    if (-not $winget) { throw 'WinGet is not available. Install App Installer from Microsoft Store and try again.' }
    Write-JevRouterLog "Installing prerequisite with WinGet: $PackageId"
    $args = @('install','--id',$PackageId,'--exact','--accept-package-agreements','--accept-source-agreements','--silent','--disable-interactivity')
    return Invoke-ProcessCaptured -FilePath $winget -ArgumentList $args -TimeoutSeconds 900
}

function Ensure-CodexBridgePrerequisites {
    $messages = New-Object System.Collections.Generic.List[string]
    Refresh-ProcessPath
    if (-not (Get-CommandPathSafe -Name 'git')) {
        $messages.Add('Installing Git for Windows…')
        [void](Install-WithWinget -PackageId 'Git.Git')
        Refresh-ProcessPath
    }
    if ((Get-NodeMajorVersion) -lt 24) {
        $messages.Add('Installing Node.js 24+…')
        [void](Install-WithWinget -PackageId 'OpenJS.NodeJS.LTS')
        Refresh-ProcessPath
    }
    if ((Get-NodeMajorVersion) -lt 24) {
        throw 'Node.js 24 or newer is required by jev-codex-bridge. Install Node.js 24+ and try again.'
    }
    return $messages
}

function Set-RestrictedFileAcl {
    param([Parameter(Mandatory)][string]$Path)
    try {
        $identity = [Security.Principal.WindowsIdentity]::GetCurrent().Name
        $acl = New-Object Security.AccessControl.FileSecurity
        $rule = New-Object Security.AccessControl.FileSystemAccessRule($identity, 'FullControl', 'Allow')
        $acl.SetAccessRuleProtection($true, $false)
        $acl.AddAccessRule($rule)
        Set-Acl -Path $Path -AclObject $acl
    } catch {
        Write-JevRouterLog "Could not tighten key-file ACL: $($_.Exception.Message)"
    }
}

function Write-CodexBridgeKeyFile {
    param([Parameter(Mandatory)][string]$ApiKey)
    $existing = @()
    if (Test-Path $script:BridgeEnvFile) {
        $existing = Get-Content $script:BridgeEnvFile -ErrorAction SilentlyContinue |
            Where-Object { $_ -notmatch '^\s*(TYPESAFE_API_KEY|JEV_API_KEY)\s*=' }
    }
    $content = @($existing) + @("TYPESAFE_API_KEY=$($ApiKey.Trim())")
    # Windows PowerShell 5.1 writes a BOM with -Encoding UTF8. Node's parseEnv
    # can then treat the first key name as BOM-prefixed, so use ASCII here.
    Set-Content -Path $script:BridgeEnvFile -Value $content -Encoding ASCII
    Set-RestrictedFileAcl -Path $script:BridgeEnvFile
    Write-JevRouterLog "Updated Codex bridge key file at $script:BridgeEnvFile"
}

function Install-CodexBridge {
    param([Parameter(Mandatory)][string]$ApiKey)
    $log = New-Object System.Collections.Generic.List[string]
    foreach ($m in (Ensure-CodexBridgePrerequisites)) { $log.Add($m) }
    Refresh-ProcessPath
    $npm = Get-CommandPathSafe -Name 'npm.cmd'
    if (-not $npm) { $npm = Get-CommandPathSafe -Name 'npm' }
    if (-not $npm) { throw 'npm was not found after installing Node.js.' }

    $log.Add('Installing Jev Codex Bridge…')
    $output = Invoke-ProcessCaptured -FilePath $npm -ArgumentList @('install','--global','git+https://github.com/ansidium/jev-codex-bridge.git','--ignore-scripts') -TimeoutSeconds 900
    if ($output) { $log.Add($output) }
    Refresh-ProcessPath

    Write-CodexBridgeKeyFile -ApiKey $ApiKey
    $bridge = Get-CommandPathSafe -Name 'jev-bridge.cmd'
    if (-not $bridge) { $bridge = Get-CommandPathSafe -Name 'jev-bridge' }
    if (-not $bridge) { throw 'jev-bridge was installed but is not on PATH yet. Close and reopen Jev Router, then try again.' }

    $log.Add('Configuring Codex Desktop and background service…')
    $installOutput = Invoke-ProcessCaptured -FilePath $bridge -ArgumentList @('install','--key-file',$script:BridgeEnvFile) -TimeoutSeconds 600
    if ($installOutput) { $log.Add($installOutput) }
    $status = Invoke-ProcessCaptured -FilePath $bridge -ArgumentList @('status') -TimeoutSeconds 60
    if ($status) { $log.Add($status) }
    Write-JevRouterLog 'Codex bridge installation finished.'
    return $log
}

function Remove-CodexBridge {
    $log = New-Object System.Collections.Generic.List[string]
    Refresh-ProcessPath
    $bridge = Get-CommandPathSafe -Name 'jev-bridge.cmd'
    if (-not $bridge) { $bridge = Get-CommandPathSafe -Name 'jev-bridge' }
    if ($bridge) {
        foreach ($args in @(@('restore-config'), @('service','remove'))) {
            try {
                $output = Invoke-ProcessCaptured -FilePath $bridge -ArgumentList $args -TimeoutSeconds 180
                if ($output) { $log.Add($output) }
            } catch { $log.Add("Warning: $($_.Exception.Message)") }
        }
    }
    $npm = Get-CommandPathSafe -Name 'npm.cmd'
    if (-not $npm) { $npm = Get-CommandPathSafe -Name 'npm' }
    if ($npm) {
        try {
            $output = Invoke-ProcessCaptured -FilePath $npm -ArgumentList @('uninstall','--global','jev-codex-bridge') -TimeoutSeconds 300
            if ($output) { $log.Add($output) }
        } catch { $log.Add("Warning: $($_.Exception.Message)") }
    }
    Remove-CodexBridgeKeyFile
    Write-JevRouterLog 'Codex bridge removal finished and Codex configuration was restored where a bridge backup was available.'
    return $log
}

function Initialize-ClaudeIntegration {
    param([Parameter(Mandatory)][string]$ApiKey)

    $log = New-Object System.Collections.Generic.List[string]
    $key = $ApiKey.Trim()

    # The plugin reads the standard TypeSafe environment variable when no
    # plugin-specific userConfig value is supplied.
    [Environment]::SetEnvironmentVariable('TYPESAFE_API_KEY', $key, 'User')
    $env:TYPESAFE_API_KEY = $key

    $cli = Ensure-ClaudeCodeCli
    foreach ($message in $cli.Messages) { $log.Add($message) }
    $claude = $cli.Path

    $marketplaceSource = 'Mandrilsquad1441/jev-model-router'
    $marketplaceName = 'jev-model-router'
    $pluginId = 'jev-model-router@jev-model-router'

    # Prefer HTTPS so a machine without GitHub SSH credentials still works.
    $previousHttpsPreference = $env:CLAUDE_CODE_PLUGIN_PREFER_HTTPS
    $env:CLAUDE_CODE_PLUGIN_PREFER_HTTPS = '1'

    try {
        $marketplaces = Invoke-ProcessCaptured -FilePath $claude -ArgumentList @('plugin','marketplace','list') -TimeoutSeconds 120
        if ($marketplaces -notmatch [regex]::Escape($marketplaceName)) {
            $log.Add('Adding Jev Model Router marketplace…')
            $added = Invoke-ProcessCaptured -FilePath $claude -ArgumentList @('plugin','marketplace','add',$marketplaceSource) -TimeoutSeconds 300
            if ($added) { $log.Add($added) }
        } else {
            $log.Add('Jev Model Router marketplace is already registered.')
        }

        $log.Add('Installing Jev Model Router for Claude Code…')
        $installed = Invoke-ProcessCaptured -FilePath $claude -ArgumentList @('plugin','install',$pluginId,'--scope','user') -TimeoutSeconds 300
        if ($installed) { $log.Add($installed) }
    } finally {
        if ($null -eq $previousHttpsPreference) {
            Remove-Item Env:CLAUDE_CODE_PLUGIN_PREFER_HTTPS -ErrorAction SilentlyContinue
        } else {
            $env:CLAUDE_CODE_PLUGIN_PREFER_HTTPS = $previousHttpsPreference
        }
    }

    Write-JevRouterLog 'Claude Jev plugin installation finished.'
    try { Start-Process 'claude://code' } catch { }

    return [pscustomobject]@{
        Marketplace = $marketplaceSource
        Plugin = $pluginId
        Message = 'Jev Model Router is installed for Claude Code. Restart or reload the Claude Code session to activate it.'
        Log = @($log)
    }
}

function Remove-ClaudeIntegration {
    $log = New-Object System.Collections.Generic.List[string]
    $claude = Get-ClaudeCodeCliPath

    if ($claude) {
        try {
            $output = Invoke-ProcessCaptured -FilePath $claude -ArgumentList @('plugin','uninstall','jev-model-router@jev-model-router','--scope','user') -TimeoutSeconds 180
            if ($output) { $log.Add($output) }
        } catch {
            $log.Add("Claude plugin removal warning: $($_.Exception.Message)")
        }

        try {
            $output = Invoke-ProcessCaptured -FilePath $claude -ArgumentList @('plugin','marketplace','remove','jev-model-router') -TimeoutSeconds 180
            if ($output) { $log.Add($output) }
        } catch {
            $log.Add("Claude marketplace removal warning: $($_.Exception.Message)")
        }
    }

    foreach ($name in @('TYPESAFE_API_KEY','JEV_API_KEY','JEV_ROUTER_TYPESAFE_API_KEY')) {
        [Environment]::SetEnvironmentVariable($name, $null, 'User')
        Remove-Item ("Env:" + $name) -ErrorAction SilentlyContinue
    }

    Write-JevRouterLog 'Removed the Claude Jev plugin where possible and cleared Jev/TypeSafe environment keys.'
    return $log
}

function Reset-JevRouterAll {
    $log = New-Object System.Collections.Generic.List[string]

    try {
        foreach ($line in (Remove-CodexBridge)) {
            if ($line) { $log.Add([string]$line) }
        }
        $log.Add('Codex routing was returned to its pre-bridge configuration where a backup was available.')
    } catch {
        $log.Add("Codex reset warning: $($_.Exception.Message)")
        try { Remove-CodexBridgeKeyFile } catch { }
    }

    try {
        Remove-ClaudeIntegration
        $log.Add('Claude Jev environment keys were removed.')
    } catch {
        $log.Add("Claude reset warning: $($_.Exception.Message)")
    }

    try {
        Remove-SavedTypeSafeKey
        $log.Add('The DPAPI-protected TypeSafe key saved by Jev Router was removed.')
    } catch {
        $log.Add("Saved-key reset warning: $($_.Exception.Message)")
    }

    Write-JevRouterLog 'Full Jev Router reset finished.'
    return $log
}

function Get-CodexBridgeStatusText {
    Refresh-ProcessPath
    $bridge = Get-CommandPathSafe -Name 'jev-bridge.cmd'
    if (-not $bridge) { $bridge = Get-CommandPathSafe -Name 'jev-bridge' }
    if (-not $bridge) { return 'Not installed' }
    try { return Invoke-ProcessCaptured -FilePath $bridge -ArgumentList @('status') -TimeoutSeconds 30 }
    catch { return "Installed, status unavailable: $($_.Exception.Message)" }
}

Export-ModuleMember -Function @(
    'Initialize-JevRouterStorage',
    'Save-TypeSafeKey',
    'Get-SavedTypeSafeKey',
    'Remove-SavedTypeSafeKey',
    'Get-JevRouterPaths',
    'Test-TypeSafeApiKey',
    'Get-SystemStatus',
    'Install-CodexBridge',
    'Remove-CodexBridge',
    'Initialize-ClaudeIntegration',
    'Remove-ClaudeIntegration',
    'Reset-JevRouterAll',
    'Get-CodexBridgeStatusText'
)
