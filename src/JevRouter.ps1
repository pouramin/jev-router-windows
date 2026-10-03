#requires -Version 5.1
param([switch]$SelfTest)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$runtimeRoot = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($runtimeRoot)) {
    $processPath = [System.Diagnostics.Process]::GetCurrentProcess().MainModule.FileName
    if (-not [string]::IsNullOrWhiteSpace($processPath)) {
        $runtimeRoot = Split-Path -Parent $processPath
    }
}
if ([string]::IsNullOrWhiteSpace($runtimeRoot)) {
    $runtimeRoot = [AppDomain]::CurrentDomain.BaseDirectory
}
if ([string]::IsNullOrWhiteSpace($runtimeRoot)) {
    throw 'Could not determine the Jev Router application directory.'
}

$modulePath = Join-Path $runtimeRoot 'RouterCore.psm1'
if (-not (Test-Path -LiteralPath $modulePath)) {
    throw "RouterCore.psm1 was not found next to the application: $modulePath"
}

Import-Module $modulePath -Force
Initialize-JevRouterStorage

if ($SelfTest -or $env:JEV_ROUTER_SELFTEST -eq '1') {
    $status = Get-SystemStatus
    Write-Output "SELFTEST_OK"
    Write-Output ("KeySaved={0}" -f $status.KeySaved)
    exit 0
}

Add-Type -AssemblyName PresentationFramework,PresentationCore,WindowsBase,System.Xaml

[xml]$xaml = @'
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
 xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml" Title="Jev Router for Windows"
 Width="920" Height="700" MinWidth="820" MinHeight="620" WindowStartupLocation="CenterScreen"
 Background="#090C13" Foreground="#EEF2F7" FontFamily="Segoe UI">
 <Window.Resources>
  <SolidColorBrush x:Key="Panel" Color="#111722"/>
  <SolidColorBrush x:Key="Border" Color="#263244"/>
  <SolidColorBrush x:Key="Muted" Color="#92A0B5"/>
  <Style TargetType="Button">
   <Setter Property="Background" Value="#202B3A"/><Setter Property="Foreground" Value="#EEF2F7"/>
   <Setter Property="BorderBrush" Value="#35445A"/><Setter Property="BorderThickness" Value="1"/>
   <Setter Property="Padding" Value="15,9"/><Setter Property="FontWeight" Value="SemiBold"/>
   <Setter Property="Cursor" Value="Hand"/>
  </Style>
  <Style TargetType="PasswordBox">
   <Setter Property="Background" Value="#0D121B"/><Setter Property="Foreground" Value="#EEF2F7"/>
   <Setter Property="BorderBrush" Value="#314057"/><Setter Property="BorderThickness" Value="1"/>
   <Setter Property="Padding" Value="12,9"/>
  </Style>
 </Window.Resources>
 <Grid Margin="26">
  <Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>

  <Grid Grid.Row="0" Margin="0,0,0,22">
   <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
   <StackPanel>
    <TextBlock Text="JEV ROUTER" Foreground="#F0C35A" FontSize="12" FontWeight="Bold"/>
    <TextBlock Text="Jev Router for Windows" FontSize="29" FontWeight="Bold" Margin="0,4,0,0"/>
    <TextBlock Text="TypeSafe Jev routing for Windows, without manual terminal setup." Foreground="{StaticResource Muted}" FontSize="13" Margin="0,7,0,0"/>
   </StackPanel>
   <Border Grid.Column="1" Background="#121B27" BorderBrush="{StaticResource Border}" BorderThickness="1" CornerRadius="16" Padding="12,7" VerticalAlignment="Top">
    <StackPanel Orientation="Horizontal"><Ellipse x:Name="GlobalDot" Width="8" Height="8" Fill="#92A0B5" Margin="0,0,7,0"/><TextBlock x:Name="GlobalStatus" Text="Ready" Foreground="{StaticResource Muted}"/></StackPanel>
   </Border>
  </Grid>

  <Border Grid.Row="1" Background="{StaticResource Panel}" BorderBrush="{StaticResource Border}" BorderThickness="1" CornerRadius="15" Padding="18" Margin="0,0,0,16">
   <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
    <StackPanel>
     <TextBlock Text="TypeSafe API key" FontWeight="SemiBold"/>
     <TextBlock Text="Verified with TypeSafe and stored locally with Windows DPAPI for this Windows user." Foreground="{StaticResource Muted}" FontSize="11" Margin="0,4,0,10"/>
     <PasswordBox x:Name="ApiKeyBox" Height="39" MaxLength="500"/>
     <TextBlock x:Name="KeyStatus" Text="Paste your TypeSafe key, then Verify &amp; save." Foreground="{StaticResource Muted}" FontSize="11" Margin="0,7,0,0"/>
    </StackPanel>
    <Button x:Name="VerifyButton" Grid.Column="1" Content="Verify &amp; save" MinWidth="130" Margin="16,24,0,0" VerticalAlignment="Top" Background="#6A5420" BorderBrush="#9B7A2E"/>
   </Grid>
  </Border>

  <Grid Grid.Row="2"><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="14"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>
   <Border Grid.Column="0" Background="{StaticResource Panel}" BorderBrush="{StaticResource Border}" BorderThickness="1" CornerRadius="15" Padding="19">
    <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
     <StackPanel>
      <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
       <StackPanel><TextBlock Text="Codex" FontSize="20" FontWeight="Bold"/><TextBlock Text="Desktop + CLI" Foreground="{StaticResource Muted}" FontSize="11"/></StackPanel>
       <Border Grid.Column="1" Background="#143B31" CornerRadius="12" Padding="9,5"><TextBlock Text="AUTOMATIC" Foreground="#64D6A6" FontSize="10" FontWeight="Bold"/></Border>
      </Grid>
      <TextBlock Text="Installs Jev Codex Bridge, configures Codex, and runs routing as a background Windows task. Jev can select model and reasoning effort per turn." TextWrapping="Wrap" Foreground="#C4CEDC" FontSize="12" LineHeight="19" Margin="0,16,0,0"/>
     </StackPanel>
     <StackPanel Grid.Row="1" Margin="0,22,0,0">
      <TextBlock x:Name="CodexDetection" Text="Checking Codex..." Foreground="{StaticResource Muted}"/>
      <TextBlock x:Name="CodexBridgeStatus" Text="Bridge: checking..." Foreground="{StaticResource Muted}" Margin="0,7,0,0"/>
      <TextBlock Text="Missing Git or Node.js can be installed with WinGet after you confirm." Foreground="#6F7D91" FontSize="10" Margin="0,14,0,0" TextWrapping="Wrap"/>
     </StackPanel>
     <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,18,0,0">
      <Button x:Name="ConnectCodexButton" Content="Connect Codex" MinWidth="128" Background="#1E4F43" BorderBrush="#2D7664"/>
      <Button x:Name="DisconnectCodexButton" Content="Disconnect" MinWidth="102" Margin="9,0,0,0"/>
     </StackPanel>
    </Grid>
   </Border>

   <Border Grid.Column="2" Background="{StaticResource Panel}" BorderBrush="{StaticResource Border}" BorderThickness="1" CornerRadius="15" Padding="19">
    <Grid><Grid.RowDefinitions><RowDefinition Height="Auto"/><RowDefinition Height="*"/><RowDefinition Height="Auto"/></Grid.RowDefinitions>
     <StackPanel>
      <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
       <StackPanel><TextBlock Text="Claude Code" FontSize="20" FontWeight="Bold"/><TextBlock Text="Claude Desktop Code tab" Foreground="{StaticResource Muted}" FontSize="11"/></StackPanel>
       <Border Grid.Column="1" Background="#202E50" CornerRadius="12" Padding="9,5"><TextBlock Text="PLUGIN" Foreground="#7EA3FF" FontSize="10" FontWeight="Bold"/></Border>
      </Grid>
      <TextBlock Text="Prepares the TypeSafe key and opens Claude. Install Jev Model Router from the graphical Plugins screen. This alpha does not claim the transparent proxy behavior used by Codex." TextWrapping="Wrap" Foreground="#C4CEDC" FontSize="12" LineHeight="19" Margin="0,16,0,0"/>
     </StackPanel>
     <StackPanel Grid.Row="1" Margin="0,22,0,0">
      <TextBlock x:Name="ClaudeDetection" Text="Checking Claude..." Foreground="{StaticResource Muted}"/>
      <TextBlock x:Name="ClaudePluginStatus" Text="Plugin: checking..." Foreground="{StaticResource Muted}" Margin="0,7,0,0"/>
      <Border Background="#0D121B" BorderBrush="#263244" BorderThickness="1" CornerRadius="8" Padding="10" Margin="0,14,0,0">
       <TextBlock x:Name="ClaudeInstructions" Text="1. Click Prepare Claude&#x0a;2. Claude opens&#x0a;3. Customize > Plugins > Add marketplace&#x0a;4. Paste the copied marketplace and install Jev Model Router" Foreground="#AAB6C7" FontSize="10.5" LineHeight="17" TextWrapping="Wrap"/>
      </Border>
     </StackPanel>
     <StackPanel Grid.Row="2" Orientation="Horizontal" Margin="0,18,0,0">
      <Button x:Name="PrepareClaudeButton" Content="Prepare Claude" MinWidth="128" Background="#2A3D66" BorderBrush="#3B5B93"/>
      <Button x:Name="OpenClaudeButton" Content="Open Claude" MinWidth="102" Margin="9,0,0,0"/>
     </StackPanel>
    </Grid>
   </Border>
  </Grid>

  <Border Grid.Row="3" Background="#0D121B" BorderBrush="{StaticResource Border}" BorderThickness="1" CornerRadius="12" Padding="12" Margin="0,16,0,0">
   <Grid><Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
    <TextBlock x:Name="FooterStatus" Text="No API calls are made until you verify the key or connect a router." Foreground="{StaticResource Muted}" FontSize="10.5" VerticalAlignment="Center" TextTrimming="CharacterEllipsis"/>
    <Button x:Name="RefreshButton" Grid.Column="1" Content="Refresh status" Padding="12,7" FontSize="10.5"/>
   </Grid>
  </Border>
 </Grid>
</Window>
'@

$reader = New-Object System.Xml.XmlNodeReader $xaml
$window = [Windows.Markup.XamlReader]::Load($reader)
function C([string]$Name) { $window.FindName($Name) }
function B([string]$Color) { New-Object Windows.Media.SolidColorBrush $Color }
function Err([string]$Message) { [Windows.MessageBox]::Show($window,$Message,'Jev Router','OK','Error') | Out-Null }

$ApiKeyBox=C 'ApiKeyBox'; $VerifyButton=C 'VerifyButton'; $KeyStatus=C 'KeyStatus'
$GlobalDot=C 'GlobalDot'; $GlobalStatus=C 'GlobalStatus'
$CodexDetection=C 'CodexDetection'; $CodexBridgeStatus=C 'CodexBridgeStatus'
$ClaudeDetection=C 'ClaudeDetection'; $ClaudePluginStatus=C 'ClaudePluginStatus'
$ConnectCodexButton=C 'ConnectCodexButton'; $DisconnectCodexButton=C 'DisconnectCodexButton'
$PrepareClaudeButton=C 'PrepareClaudeButton'; $OpenClaudeButton=C 'OpenClaudeButton'
$RefreshButton=C 'RefreshButton'; $FooterStatus=C 'FooterStatus'; $ClaudeInstructions=C 'ClaudeInstructions'

$script:Busy=$false
$script:ActiveJob=$null
$script:Timer=New-Object Windows.Threading.DispatcherTimer
$script:Timer.Interval=[TimeSpan]::FromMilliseconds(400)

function Busy([bool]$Value,[string]$Message='Working...') {
 foreach($x in @($VerifyButton,$ConnectCodexButton,$DisconnectCodexButton,$PrepareClaudeButton,$RefreshButton)){ $x.IsEnabled=-not $Value }
 $script:Busy=$Value; $GlobalStatus.Text=$(if($Value){$Message}else{'Ready'}); $GlobalDot.Fill=B $(if($Value){'#F0C35A'}else{'#92A0B5'})
}

function Refresh-Ui {
 try {
  $s=Get-SystemStatus
  $CodexDetection.Text=$(if($s.Codex){'Codex: detected'}else{'Codex: not detected yet'})
  $CodexBridgeStatus.Text=$(if($s.CodexBridge){'Jev Bridge: installed'}else{'Jev Bridge: not installed'})
  $ClaudeDetection.Text=$(if($s.ClaudeDesktop){'Claude Desktop: detected'}else{'Claude Desktop: not detected yet'})
  $ClaudePluginStatus.Text=$(if($s.ClaudePlugin){'Jev Model Router plugin: detected'}else{'Jev Model Router plugin: not detected'})
  $CodexDetection.Foreground=B $(if($s.Codex){'#64D6A6'}else{'#92A0B5'})
  $CodexBridgeStatus.Foreground=B $(if($s.CodexBridge){'#64D6A6'}else{'#92A0B5'})
  $ClaudeDetection.Foreground=B $(if($s.ClaudeDesktop){'#64D6A6'}else{'#92A0B5'})
  $ClaudePluginStatus.Foreground=B $(if($s.ClaudePlugin){'#64D6A6'}else{'#92A0B5'})
  if($s.KeySaved){ $KeyStatus.Text='A TypeSafe key is saved for this Windows user.'; $KeyStatus.Foreground=B '#64D6A6' }
  $git=$(if($s.Git){'ready'}else{'missing'}); $wg=$(if($s.Winget){'ready'}else{'missing'})
  $FooterStatus.Text='Node '+$s.NodeMajor+' | Git '+$git+' | WinGet '+$wg
 } catch { $FooterStatus.Text='Status check failed: '+$_.Exception.Message }
}

function Background([string]$Action) {
 if($script:Busy){return}; Busy $true $Action; $m=Join-Path $PSScriptRoot 'RouterCore.psm1'
 $script:ActiveJob=Start-Job -ArgumentList $m,$Action -ScriptBlock {
  param($Module,$Name); Import-Module $Module -Force
  try {
   if($Name -eq 'Connect Codex'){
    $key=Get-SavedTypeSafeKey; if(-not $key){throw 'Save a valid TypeSafe key first.'}
    $r=Install-CodexBridge -ApiKey $key
   } else { $r=Remove-CodexBridge }
   [pscustomobject]@{Success=$true;Action=$Name;Text=($r -join [Environment]::NewLine)}
  } catch { [pscustomobject]@{Success=$false;Action=$Name;Text=$_.Exception.Message} }
 }
 $script:Timer.Start()
}

$script:Timer.Add_Tick({
 if(-not $script:ActiveJob -or $script:ActiveJob.State -notin @('Completed','Failed','Stopped')){return}
 $r=Receive-Job $script:ActiveJob -ErrorAction SilentlyContinue|Select-Object -Last 1
 Remove-Job $script:ActiveJob -Force -ErrorAction SilentlyContinue; $script:ActiveJob=$null; $script:Timer.Stop(); Busy $false; Refresh-Ui
 if($r -and -not $r.Success){Err $r.Text}
 elseif($r -and $r.Action -eq 'Connect Codex'){[Windows.MessageBox]::Show($window,"Codex is configured. Restart Codex Desktop, then choose 'Jev Router' from its model picker.",'Codex connected','OK','Information')|Out-Null}
})

$VerifyButton.Add_Click({
 $key=$ApiKeyBox.Password.Trim(); if(-not $key){$key=Get-SavedTypeSafeKey}; if(-not $key){Err 'Paste your TypeSafe API key first.';return}
 Busy $true 'Verifying TypeSafe...'
 try{$r=Test-TypeSafeApiKey -ApiKey $key;if(-not $r.Success){throw $r.Message};Save-TypeSafeKey -ApiKey $key;$ApiKeyBox.Password='';$KeyStatus.Text='Verified. Available Jev models: '+($r.Models -join ', ');$KeyStatus.Foreground=B '#64D6A6'}
 catch{$KeyStatus.Text='Verification failed.';$KeyStatus.Foreground=B '#FF8585';Err $_.Exception.Message}
 finally{Busy $false;Refresh-Ui}
})

$ConnectCodexButton.Add_Click({
 if(-not(Get-SavedTypeSafeKey)){Err 'Verify and save your TypeSafe API key first.';return}
 $q='This can install Git and Node.js with WinGet, install jev-codex-bridge, back up Codex configuration, and add a user-level background task. Continue?'
 if([Windows.MessageBox]::Show($window,$q,'Connect Codex','YesNo','Question') -eq 'Yes'){Background 'Connect Codex'}
})
$DisconnectCodexButton.Add_Click({if([Windows.MessageBox]::Show($window,'Restore Codex configuration and remove Jev Codex Bridge?','Disconnect Codex','YesNo','Question') -eq 'Yes'){Background 'Disconnect Codex'}})
$PrepareClaudeButton.Add_Click({
 $key=Get-SavedTypeSafeKey;if(-not $key){Err 'Verify and save your TypeSafe API key first.';return}
 try{$r=Prepare-ClaudeIntegration -ApiKey $key;$ClaudeInstructions.Text='Marketplace copied: '+$r.Marketplace+[Environment]::NewLine+[Environment]::NewLine+'In Claude: Customize > Plugins > Add > Add marketplace > paste > install Jev Model Router.';$FooterStatus.Text='Claude opened and marketplace copied.'}catch{Err $_.Exception.Message}
})
$OpenClaudeButton.Add_Click({try{Start-Process 'claude://code'}catch{Err 'Claude Desktop could not be opened.'}})
$RefreshButton.Add_Click({Refresh-Ui})
$window.Add_Closed({if($script:ActiveJob){Stop-Job $script:ActiveJob -ErrorAction SilentlyContinue;Remove-Job $script:ActiveJob -Force -ErrorAction SilentlyContinue}})
Refresh-Ui
[void]$window.ShowDialog()
