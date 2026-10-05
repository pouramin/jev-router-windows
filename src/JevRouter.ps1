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
 xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
 Title="Jev Router for Windows"
 Width="1120" Height="760" MinWidth="900" MinHeight="680"
 WindowStartupLocation="CenterScreen"
 Background="#080B11" Foreground="#F4F7FB"
 FontFamily="Segoe UI"
 SnapsToDevicePixels="True">
 <Window.Resources>
  <SolidColorBrush x:Key="Panel" Color="#101722"/>
  <SolidColorBrush x:Key="PanelSoft" Color="#0D131D"/>
  <SolidColorBrush x:Key="Border" Color="#243247"/>
  <SolidColorBrush x:Key="BorderStrong" Color="#33445F"/>
  <SolidColorBrush x:Key="Text" Color="#F4F7FB"/>
  <SolidColorBrush x:Key="Muted" Color="#93A2B8"/>
  <SolidColorBrush x:Key="Muted2" Color="#6F8098"/>
  <SolidColorBrush x:Key="Accent" Color="#F0C35A"/>
  <SolidColorBrush x:Key="Green" Color="#63D5A5"/>
  <SolidColorBrush x:Key="Blue" Color="#82A4FF"/>

  <Style x:Key="PrimaryButton" TargetType="Button">
   <Setter Property="Background" Value="#6B5420"/>
   <Setter Property="Foreground" Value="#FFF8E6"/>
   <Setter Property="BorderBrush" Value="#9A7A2D"/>
   <Setter Property="BorderThickness" Value="1"/>
   <Setter Property="Padding" Value="18,10"/>
   <Setter Property="FontWeight" Value="SemiBold"/>
   <Setter Property="Cursor" Value="Hand"/>
   <Setter Property="Template">
    <Setter.Value>
     <ControlTemplate TargetType="Button">
      <Border x:Name="ButtonBorder" Background="{TemplateBinding Background}" BorderBrush="{TemplateBinding BorderBrush}"
              BorderThickness="{TemplateBinding BorderThickness}" CornerRadius="9" Padding="{TemplateBinding Padding}">
       <ContentPresenter HorizontalAlignment="Center" VerticalAlignment="Center"/>
      </Border>
      <ControlTemplate.Triggers>
       <Trigger Property="IsMouseOver" Value="True"><Setter TargetName="ButtonBorder" Property="Background" Value="#826725"/></Trigger>
       <Trigger Property="IsPressed" Value="True"><Setter TargetName="ButtonBorder" Property="Opacity" Value="0.86"/></Trigger>
       <Trigger Property="IsEnabled" Value="False"><Setter TargetName="ButtonBorder" Property="Opacity" Value="0.45"/></Trigger>
      </ControlTemplate.Triggers>
     </ControlTemplate>
    </Setter.Value>
   </Setter>
  </Style>

  <Style x:Key="GreenButton" TargetType="Button" BasedOn="{StaticResource PrimaryButton}">
   <Setter Property="Background" Value="#174C3F"/>
   <Setter Property="BorderBrush" Value="#2D7864"/>
   <Setter Property="Foreground" Value="#DFFFF4"/>
  </Style>

  <Style x:Key="BlueButton" TargetType="Button" BasedOn="{StaticResource PrimaryButton}">
   <Setter Property="Background" Value="#263E73"/>
   <Setter Property="BorderBrush" Value="#4164A8"/>
   <Setter Property="Foreground" Value="#EEF3FF"/>
  </Style>

  <Style x:Key="SecondaryButton" TargetType="Button" BasedOn="{StaticResource PrimaryButton}">
   <Setter Property="Background" Value="#172131"/>
   <Setter Property="BorderBrush" Value="#304158"/>
   <Setter Property="Foreground" Value="#D7E0EB"/>
  </Style>

  <Style TargetType="PasswordBox">
   <Setter Property="Background" Value="#0A1018"/>
   <Setter Property="Foreground" Value="#F4F7FB"/>
   <Setter Property="BorderBrush" Value="#304158"/>
   <Setter Property="BorderThickness" Value="1"/>
   <Setter Property="Padding" Value="13,10"/>
   <Setter Property="FontSize" Value="13"/>
   <Setter Property="CaretBrush" Value="#F0C35A"/>
  </Style>
 </Window.Resources>

 <ScrollViewer VerticalScrollBarVisibility="Auto" HorizontalScrollBarVisibility="Disabled">
  <Grid Margin="28,24,28,26" MaxWidth="1180" HorizontalAlignment="Center">
   <Grid.RowDefinitions>
    <RowDefinition Height="Auto"/>
    <RowDefinition Height="Auto"/>
    <RowDefinition Height="Auto"/>
    <RowDefinition Height="Auto"/>
   </Grid.RowDefinitions>

   <!-- Header -->
   <Grid Grid.Row="0" Margin="0,0,0,22">
    <Grid.ColumnDefinitions>
     <ColumnDefinition Width="Auto"/>
     <ColumnDefinition Width="*"/>
     <ColumnDefinition Width="Auto"/>
    </Grid.ColumnDefinitions>

    <Border Width="52" Height="52" CornerRadius="14" Background="#E8B94B" VerticalAlignment="Center">
     <TextBlock Text="J" Foreground="#0C1016" FontSize="24" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
    </Border>

    <StackPanel Grid.Column="1" Margin="15,1,0,0" VerticalAlignment="Center">
     <TextBlock Text="Jev Router for Windows" FontSize="25" FontWeight="Bold"/>
     <TextBlock Text="TypeSafe Jev routing for Windows - simple setup, clear status, no manual terminal work."
                Foreground="{StaticResource Muted}" FontSize="12.5" Margin="0,5,0,0"/>
    </StackPanel>

    <Border Grid.Column="2" Background="#101923" BorderBrush="#26364A" BorderThickness="1" CornerRadius="16"
            Padding="12,7" VerticalAlignment="Center">
     <StackPanel Orientation="Horizontal">
      <Ellipse x:Name="GlobalDot" Width="8" Height="8" Fill="#92A0B5" Margin="0,0,7,0" VerticalAlignment="Center"/>
      <TextBlock x:Name="GlobalStatus" Text="Ready" Foreground="#A9B6C8" FontSize="11.5" VerticalAlignment="Center"/>
     </StackPanel>
    </Border>
   </Grid>

   <!-- TypeSafe access -->
   <Border Grid.Row="1" Background="{StaticResource Panel}" BorderBrush="{StaticResource Border}"
           BorderThickness="1" CornerRadius="16" Padding="20" Margin="0,0,0,16">
    <Grid>
     <Grid.RowDefinitions>
      <RowDefinition Height="Auto"/>
      <RowDefinition Height="Auto"/>
     </Grid.RowDefinitions>

     <Grid>
      <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
      <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
       <Border Width="30" Height="30" CornerRadius="9" Background="#332A15" Margin="0,0,11,0">
        <TextBlock Text="1" Foreground="{StaticResource Accent}" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
       </Border>
       <StackPanel>
        <TextBlock Text="Connect TypeSafe" FontSize="15" FontWeight="SemiBold"/>
        <TextBlock Text="Your API key is verified with TypeSafe and stored locally for this Windows user."
                   Foreground="{StaticResource Muted}" FontSize="10.5" Margin="0,3,0,0"/>
       </StackPanel>
      </StackPanel>
      <TextBlock Grid.Column="1" x:Name="KeyStatus" Text="Not connected" Foreground="{StaticResource Muted}"
                 FontSize="10.5" VerticalAlignment="Center"/>
     </Grid>

     <Grid Grid.Row="1" Margin="41,15,0,0">
      <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="12"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
      <PasswordBox x:Name="ApiKeyBox" Height="42" MaxLength="500" VerticalContentAlignment="Center"/>
      <Button x:Name="VerifyButton" Grid.Column="2" Content="Verify &amp; save" MinWidth="132" Height="42"
              Style="{StaticResource PrimaryButton}"/>
     </Grid>
    </Grid>
   </Border>

   <!-- Integrations -->
   <Grid Grid.Row="2">
    <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="16"/><ColumnDefinition Width="*"/></Grid.ColumnDefinitions>

    <!-- Codex card -->
    <Border Grid.Column="0" Background="{StaticResource Panel}" BorderBrush="{StaticResource Border}"
            BorderThickness="1" CornerRadius="16" Padding="20">
     <Grid>
      <Grid.RowDefinitions>
       <RowDefinition Height="Auto"/>
       <RowDefinition Height="Auto"/>
       <RowDefinition Height="Auto"/>
       <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>

      <Grid>
       <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
       <Border Width="42" Height="42" CornerRadius="12" Background="#143C34">
        <TextBlock Text="C" Foreground="{StaticResource Green}" FontSize="18" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
       </Border>
       <StackPanel Grid.Column="1" Margin="12,0,0,0" VerticalAlignment="Center">
        <TextBlock Text="Codex" FontSize="19" FontWeight="Bold"/>
        <TextBlock Text="Desktop + CLI" Foreground="{StaticResource Muted}" FontSize="10.5" Margin="0,2,0,0"/>
       </StackPanel>
       <Border Grid.Column="2" Background="#123C31" BorderBrush="#1E5D4C" BorderThickness="1" CornerRadius="12" Padding="9,5" VerticalAlignment="Top">
        <TextBlock Text="AUTOMATIC" Foreground="{StaticResource Green}" FontSize="9.5" FontWeight="Bold"/>
       </Border>
      </Grid>

      <TextBlock Grid.Row="1" Text="Automatic per-turn routing through Jev Codex Bridge. Jev can select the model and reasoning effort while Codex keeps your existing sign-in."
                 TextWrapping="Wrap" Foreground="#C9D2DE" FontSize="11.5" LineHeight="18" Margin="0,16,0,0"/>

      <Border Grid.Row="2" Background="{StaticResource PanelSoft}" BorderBrush="#1E2B3D" BorderThickness="1" CornerRadius="11" Padding="13" Margin="0,16,0,0">
       <StackPanel>
        <Grid>
         <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
         <TextBlock Text="Codex app" Foreground="{StaticResource Muted}" FontSize="10.5"/>
         <TextBlock x:Name="CodexDetection" Grid.Column="1" Text="Checking..." Foreground="{StaticResource Muted}" FontSize="10.5" FontWeight="SemiBold"/>
        </Grid>
        <Border Height="1" Background="#1D2939" Margin="0,10"/>
        <Grid>
         <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
         <TextBlock Text="Jev Bridge" Foreground="{StaticResource Muted}" FontSize="10.5"/>
         <TextBlock x:Name="CodexBridgeStatus" Grid.Column="1" Text="Checking..." Foreground="{StaticResource Muted}" FontSize="10.5" FontWeight="SemiBold"/>
        </Grid>
       </StackPanel>
      </Border>

      <Grid Grid.Row="3" Margin="0,18,0,0">
       <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="10"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
       <Button x:Name="ConnectCodexButton" Content="Connect Codex" Height="42" Style="{StaticResource GreenButton}"/>
       <Button x:Name="DisconnectCodexButton" Grid.Column="2" Content="Disconnect" Height="42" MinWidth="102" Style="{StaticResource SecondaryButton}"/>
      </Grid>
     </Grid>
    </Border>

    <!-- Claude card -->
    <Border Grid.Column="2" Background="{StaticResource Panel}" BorderBrush="{StaticResource Border}"
            BorderThickness="1" CornerRadius="16" Padding="20">
     <Grid>
      <Grid.RowDefinitions>
       <RowDefinition Height="Auto"/>
       <RowDefinition Height="Auto"/>
       <RowDefinition Height="Auto"/>
       <RowDefinition Height="Auto"/>
       <RowDefinition Height="Auto"/>
      </Grid.RowDefinitions>

      <Grid>
       <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
       <Border Width="42" Height="42" CornerRadius="12" Background="#202D52">
        <TextBlock Text="A" Foreground="{StaticResource Blue}" FontSize="18" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
       </Border>
       <StackPanel Grid.Column="1" Margin="12,0,0,0" VerticalAlignment="Center">
        <TextBlock Text="Claude Code" FontSize="19" FontWeight="Bold"/>
        <TextBlock Text="Claude Desktop - Code tab" Foreground="{StaticResource Muted}" FontSize="10.5" Margin="0,2,0,0"/>
       </StackPanel>
       <Border Grid.Column="2" Background="#1D2C52" BorderBrush="#30477E" BorderThickness="1" CornerRadius="12" Padding="9,5" VerticalAlignment="Top">
        <TextBlock Text="PLUGIN" Foreground="{StaticResource Blue}" FontSize="9.5" FontWeight="Bold"/>
       </Border>
      </Grid>

      <TextBlock Grid.Row="1" Text="Automatic Claude Code plugin setup. Jev Router installs the Claude Code CLI if needed, adds the marketplace, installs Jev Model Router for this user, then opens Claude."
                 TextWrapping="Wrap" Foreground="#C9D2DE" FontSize="11.5" LineHeight="18" Margin="0,16,0,0"/>

      <Border Grid.Row="2" Background="{StaticResource PanelSoft}" BorderBrush="#1E2B3D" BorderThickness="1" CornerRadius="11" Padding="13" Margin="0,16,0,0">
       <StackPanel>
        <Grid>
         <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
         <TextBlock Text="Claude Desktop" Foreground="{StaticResource Muted}" FontSize="10.5"/>
         <TextBlock x:Name="ClaudeDetection" Grid.Column="1" Text="Checking..." Foreground="{StaticResource Muted}" FontSize="10.5" FontWeight="SemiBold"/>
        </Grid>
        <Border Height="1" Background="#1D2939" Margin="0,10"/>
        <Grid>
         <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
         <TextBlock Text="Jev Model Router" Foreground="{StaticResource Muted}" FontSize="10.5"/>
         <TextBlock x:Name="ClaudePluginStatus" Grid.Column="1" Text="Checking..." Foreground="{StaticResource Muted}" FontSize="10.5" FontWeight="SemiBold"/>
        </Grid>
       </StackPanel>
      </Border>

      <TextBlock x:Name="ClaudeInstructions" Grid.Row="3"
                 Text="One click setup. If Claude Code CLI is missing, Jev Router installs it with WinGet. Restart or reload Claude Code after first install."
                 TextWrapping="Wrap" Foreground="{StaticResource Muted}" FontSize="10.5" LineHeight="16" Margin="0,14,0,0"/>

      <Grid Grid.Row="4" Margin="0,18,0,0">
       <Grid.ColumnDefinitions><ColumnDefinition Width="*"/><ColumnDefinition Width="10"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
       <Button x:Name="PrepareClaudeButton" Content="Connect Claude" Height="42" Style="{StaticResource BlueButton}"/>
       <Button x:Name="OpenClaudeButton" Grid.Column="2" Content="Open Claude" Height="42" MinWidth="102" Style="{StaticResource SecondaryButton}"/>
      </Grid>
     </Grid>
    </Border>
   </Grid>

   <!-- Footer -->
   <Border Grid.Row="3" Background="#0C121B" BorderBrush="#1F2C3D" BorderThickness="1"
           CornerRadius="12" Padding="12,10" Margin="0,16,0,0">
    <Grid>
     <Grid.ColumnDefinitions><ColumnDefinition Width="Auto"/><ColumnDefinition Width="*"/><ColumnDefinition Width="Auto"/><ColumnDefinition Width="8"/><ColumnDefinition Width="Auto"/></Grid.ColumnDefinitions>
     <StackPanel Orientation="Horizontal" VerticalAlignment="Center">
      <Border Background="#121D2A" CornerRadius="8" Padding="9,5" Margin="0,0,7,0">
       <TextBlock Text="SYSTEM" Foreground="{StaticResource Muted2}" FontSize="9.5" FontWeight="Bold"/>
      </Border>
      <TextBlock x:Name="FooterStatus" Text="Checking Windows prerequisites..." Foreground="{StaticResource Muted}" FontSize="10.5" VerticalAlignment="Center"/>
     </StackPanel>
     <TextBlock Grid.Column="1" Text="Alpha - community integration" Foreground="#52637A" FontSize="9.5" HorizontalAlignment="Center" VerticalAlignment="Center"/>
     <Button x:Name="RefreshButton" Grid.Column="2" Content="Refresh status" Height="34" Padding="12,6" Style="{StaticResource SecondaryButton}" FontSize="10.5"/>
     <Button x:Name="ResetButton" Grid.Column="4" Content="Reset JEV" Height="34" Padding="12,6"
             Background="#2A171A" Foreground="#FFB4B4" BorderBrush="#60333B" BorderThickness="1"
             FontWeight="SemiBold" Cursor="Hand" ToolTip="Restore Codex defaults and remove TypeSafe/Jev credentials saved by this app."/>
    </Grid>
   </Border>
  </Grid>
 </ScrollViewer>
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
$RefreshButton=C 'RefreshButton'; $ResetButton=C 'ResetButton'; $FooterStatus=C 'FooterStatus'; $ClaudeInstructions=C 'ClaudeInstructions'

$script:Busy=$false
$script:ActivePowerShell=$null
$script:ActiveAsync=$null
$script:Timer=New-Object Windows.Threading.DispatcherTimer
$script:Timer.Interval=[TimeSpan]::FromMilliseconds(400)

function Busy([bool]$Value,[string]$Message='Working...') {
 foreach($x in @($VerifyButton,$ConnectCodexButton,$DisconnectCodexButton,$PrepareClaudeButton,$RefreshButton,$ResetButton)){ $x.IsEnabled=-not $Value }
 $script:Busy=$Value; $GlobalStatus.Text=$(if($Value){$Message}else{'Ready'}); $GlobalDot.Fill=B $(if($Value){'#F0C35A'}else{'#92A0B5'})
}

function Refresh-Ui {
 try {
  $s=Get-SystemStatus
  $CodexDetection.Text=$(if($s.Codex){'Detected'}else{'Not detected'})
  $CodexBridgeStatus.Text=$(if($s.CodexBridge){'Installed'}else{'Not installed'})
  $ClaudeDetection.Text=$(if($s.ClaudeDesktop){'Detected'}else{'Not detected'})
  $ClaudePluginStatus.Text=$(if($s.ClaudePlugin){'Installed'}else{'Not installed'})
  $CodexDetection.Foreground=B $(if($s.Codex){'#64D6A6'}else{'#92A0B5'})
  $CodexBridgeStatus.Foreground=B $(if($s.CodexBridge){'#64D6A6'}else{'#92A0B5'})
  $ClaudeDetection.Foreground=B $(if($s.ClaudeDesktop){'#64D6A6'}else{'#92A0B5'})
  $ClaudePluginStatus.Foreground=B $(if($s.ClaudePlugin){'#64D6A6'}else{'#92A0B5'})
  if($s.KeySaved){ $KeyStatus.Text='Saved locally'; $KeyStatus.Foreground=B '#64D6A6' } else { $KeyStatus.Text='Not connected'; $KeyStatus.Foreground=B '#92A0B5' }
  $git=$(if($s.Git){'ready'}else{'missing'}); $wg=$(if($s.Winget){'ready'}else{'missing'})
  $FooterStatus.Text='Node '+$s.NodeMajor+' | Git '+$git+' | WinGet '+$wg
 } catch { $FooterStatus.Text='Status check failed: '+$_.Exception.Message }
}

function Background([string]$Action) {
 if($script:Busy){return}
 Busy $true $Action
 $m=Join-Path $PSScriptRoot 'RouterCore.psm1'

 $worker=@'
param($Module,$Name)
$ErrorActionPreference='Stop'
Import-Module $Module -Force
try {
 if($Name -eq 'Connect Codex'){
  $key=Get-SavedTypeSafeKey
  if(-not $key){throw 'Save a valid TypeSafe key first.'}
  $result=Install-CodexBridge -ApiKey $key
 } elseif($Name -eq 'Disconnect Codex'){
  $result=Remove-CodexBridge
 } elseif($Name -eq 'Connect Claude'){
  $key=Get-SavedTypeSafeKey
  if(-not $key){throw 'Save a valid TypeSafe key first.'}
  $result=Initialize-ClaudeIntegration -ApiKey $key
 } elseif($Name -eq 'Reset All'){
  $result=Reset-JevRouterAll
 } else {
  throw "Unknown action: $Name"
 }
 $text = if($result -and $result.PSObject.Properties['Message']){
  [string]$result.Message
 } else {
  ($result -join [Environment]::NewLine)
 }
 [pscustomobject]@{
  Success=$true
  Action=$Name
  Text=$text
 }
} catch {
 [pscustomobject]@{
  Success=$false
  Action=$Name
  Text=$_.Exception.Message
 }
}
'@

 try {
  $script:ActivePowerShell=[PowerShell]::Create()
  [void]$script:ActivePowerShell.AddScript($worker).AddArgument($m).AddArgument($Action)
  $script:ActiveAsync=$script:ActivePowerShell.BeginInvoke()
  $script:Timer.Start()
 } catch {
  if($script:ActivePowerShell){
   $script:ActivePowerShell.Dispose()
   $script:ActivePowerShell=$null
  }
  $script:ActiveAsync=$null
  Busy $false
  Err $_.Exception.Message
 }
}

$script:Timer.Add_Tick({
 if(-not $script:ActivePowerShell -or -not $script:ActiveAsync -or -not $script:ActiveAsync.IsCompleted){return}

 $result=$null
 try {
  $items=$script:ActivePowerShell.EndInvoke($script:ActiveAsync)
  $result=@($items)|Select-Object -Last 1
 } catch {
  $result=[pscustomobject]@{
   Success=$false
   Action='Background task'
   Text=$_.Exception.Message
  }
 } finally {
  try{$script:ActivePowerShell.Dispose()}catch{}
  $script:ActivePowerShell=$null
  $script:ActiveAsync=$null
  $script:Timer.Stop()
  Busy $false
  Refresh-Ui
 }

 if($result -and -not $result.Success){Err $result.Text}
 elseif($result -and $result.Action -eq 'Connect Codex'){[Windows.MessageBox]::Show($window,"Codex is configured. Restart Codex Desktop, then choose 'Jev Router' from its model picker.",'Codex connected','OK','Information')|Out-Null}
 elseif($result -and $result.Action -eq 'Connect Claude'){
  $ClaudeInstructions.Text='Jev Model Router installed. Restart or reload the Claude Code session to activate it.'
  $FooterStatus.Text='Claude plugin installed.'
  [Windows.MessageBox]::Show($window,"Jev Model Router is installed for Claude Code. Restart or reload the Claude Code session to activate it.",'Claude connected','OK','Information')|Out-Null
 }
 elseif($result -and $result.Action -eq 'Reset All'){[Windows.MessageBox]::Show($window,"Jev Router data was reset. Codex was restored where a bridge backup was available, the Claude plugin was removed where possible, and Jev/TypeSafe credentials saved by this app were removed.",'JEV reset complete','OK','Information')|Out-Null}
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
$ResetButton.Add_Click({
 $msg='Reset everything configured by Jev Router? This restores Codex from the bridge backup when available, removes the Codex bridge, removes the Claude Jev plugin where possible, clears Jev/TypeSafe environment keys, deletes the protected TypeSafe key saved by this app, and removes Jev keys from the bridge environment file.'
 if([Windows.MessageBox]::Show($window,$msg,'Reset JEV','YesNo','Warning') -eq 'Yes'){Background 'Reset All'}
})
$PrepareClaudeButton.Add_Click({
 if(-not(Get-SavedTypeSafeKey)){Err 'Verify and save your TypeSafe API key first.';return}
 $q='This can install the official Claude Code CLI with WinGet if it is missing, add the Jev Model Router marketplace, install the plugin at user scope, and open Claude. Continue?'
 if([Windows.MessageBox]::Show($window,$q,'Connect Claude','YesNo','Question') -eq 'Yes'){Background 'Connect Claude'}
})
$OpenClaudeButton.Add_Click({try{Start-Process 'claude://code'}catch{Err 'Claude Desktop could not be opened.'}})
$RefreshButton.Add_Click({Refresh-Ui})
$window.Add_Closed({
 $script:Timer.Stop()
 if($script:ActivePowerShell){
  try{
   if($script:ActiveAsync -and -not $script:ActiveAsync.IsCompleted){
    $script:ActivePowerShell.Stop()
   }
  }catch{}
  try{$script:ActivePowerShell.Dispose()}catch{}
  $script:ActivePowerShell=$null
  $script:ActiveAsync=$null
 }
})
Refresh-Ui
[void]$window.ShowDialog()
