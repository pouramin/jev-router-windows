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
    $root = Join-Path $HOME '.claude'
    if (-not (Test-Path $root)) { return $false }
    try {
        $hit = Get-ChildItem -Path $root -Recurse -Force -ErrorAction SilentlyContinue |
            Where-Object { $_.FullName -match 'jev-model-router' } |
            Select-Object -First 1
        return [bool]$hit
    } catch { return $false }
}

function Test-CodexBridgePresent {
    Refresh-ProcessPath
    return [bool](Get-CommandPathSafe -Name 'jev-bridge')
}

function Get-SystemStatus {
    Refresh-ProcessPath
    return [pscustomobject]@{
        ClaudeDesktop = Test-ClaudeDesktopInstalled
        ClaudeCodeCommand = [bool](Get-CommandPathSafe -Name 'claude')
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
    Set-Content -Path $script:BridgeEnvFile -Value $content -Encoding UTF8
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
    $installOutput = Invoke-ProcessCaptured -FilePath $bridge -ArgumentList @('install') -TimeoutSeconds 600
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

function Prepare-ClaudeIntegration {
    param([Parameter(Mandatory)][string]$ApiKey)
    [Environment]::SetEnvironmentVariable('TYPESAFE_API_KEY', $ApiKey.Trim(), 'User')
    $marketplace = 'Mandrilsquad1441/jev-model-router'
    try { Set-Clipboard -Value $marketplace } catch { }
    Write-JevRouterLog 'Prepared Claude plugin setup and stored TYPESAFE_API_KEY in the user environment.'
    try { Start-Process 'claude://code' } catch { }
    return [pscustomobject]@{
        Marketplace = $marketplace
        Message = 'Claude is ready for plugin setup. The marketplace name was copied to your clipboard.'
    }
}

function Remove-ClaudeIntegration {
    foreach ($name in @('TYPESAFE_API_KEY','JEV_API_KEY','JEV_ROUTER_TYPESAFE_API_KEY')) {
        [Environment]::SetEnvironmentVariable($name, $null, 'User')
        Remove-Item ("Env:" + $name) -ErrorAction SilentlyContinue
    }
    Write-JevRouterLog 'Removed Jev/TypeSafe environment keys used by the Claude integration. Account-level plugin removal remains inside Claude Customize > Plugins.'
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

Export-ModuleMember -Function *
