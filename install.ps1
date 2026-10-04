#requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$root = Join-Path $env:LOCALAPPDATA 'JevRouterForWindows\cli'
$bin = Join-Path $env:LOCALAPPDATA 'JevRouterForWindows\bin'
$base = 'https://raw.githubusercontent.com/pouramin/jev-router-windows/main'

New-Item -ItemType Directory -Path $root -Force | Out-Null
New-Item -ItemType Directory -Path $bin -Force | Out-Null

Write-Host 'Downloading Jev Router CLI...' -ForegroundColor Cyan
Invoke-WebRequest -UseBasicParsing -Uri ($base + '/cli/JevRouterCLI.ps1') -OutFile (Join-Path $root 'JevRouterCLI.ps1')
Invoke-WebRequest -UseBasicParsing -Uri ($base + '/src/RouterCore.psm1') -OutFile (Join-Path $root 'RouterCore.psm1')

$launcher = '@echo off' + [Environment]::NewLine +
            'powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File "' + (Join-Path $root 'JevRouterCLI.ps1') + '" %*' + [Environment]::NewLine
Set-Content -Path (Join-Path $bin 'jev-router.cmd') -Value $launcher -Encoding ASCII

$userPath = [Environment]::GetEnvironmentVariable('Path','User')
$parts = @($userPath -split ';' | Where-Object { $_ })
if ($parts -notcontains $bin) {
    $newPath = (($parts + $bin) -join ';')
    [Environment]::SetEnvironmentVariable('Path',$newPath,'User')
}

Write-Host ''
Write-Host 'Installed.' -ForegroundColor Green
Write-Host ('Command: jev-router') -ForegroundColor Gray
Write-Host ('Location: ' + $root) -ForegroundColor Gray
Write-Host ''
Write-Host 'Starting setup...' -ForegroundColor Cyan
& powershell.exe -NoLogo -NoProfile -ExecutionPolicy Bypass -File (Join-Path $root 'JevRouterCLI.ps1')
