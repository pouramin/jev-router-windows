#requires -Version 5.1
param([switch]$SelfTest,[switch]$XamlTest)

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
 WindowState="Maximized"
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

  <Style x:Key="DangerButton" TargetType="Button" BasedOn="{StaticResource PrimaryButton}">
   <Setter Property="Background" Value="#2A171A"/>
   <Setter Property="BorderBrush" Value="#60333B"/>
   <Setter Property="Foreground" Value="#FFB4B4"/>
  </Style>

  <Style x:Key="SocialButton" TargetType="Button" BasedOn="{StaticResource SecondaryButton}">
   <Setter Property="Height" Value="34"/>
   <Setter Property="Padding" Value="10,6"/>
   <Setter Property="MinWidth" Value="38"/>
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

    <Border Width="58" Height="52" CornerRadius="14" Background="#F4F7FB" BorderBrush="#D9E2EC" BorderThickness="1" Padding="5" VerticalAlignment="Center">
     <Viewbox Stretch="Uniform">
      <Canvas Width="620" Height="520">
       <Path Fill="#212E4E"
             Data="M4710 8891 c-85 -18 -152 -76 -175 -155 -18 -60 -21 -486 -4 -564 13 -61 66 -127 123 -153 38 -17 78 -19 574 -19 l532 0 0 -1415 c0 -980 3 -1430 11 -1465 15 -68 72 -140 140 -174 l53 -26 464 0 464 0 -57 46 c-127 104 -257 310 -306 489 -21 74 -23 106 -27 433 -3 319 -5 354 -20 359 -111 37 -215 114 -272 203 -88 136 -96 332 -20 480 47 93 152 185 251 221 l59 22 0 131 c0 159 11 230 52 344 87 239 287 421 543 493 80 23 84 23 1028 28 l949 6 24 28 c26 31 31 79 11 112 -7 12 -127 133 -267 271 -223 218 -263 253 -320 279 l-65 30 -1855 1 c-1020 1 -1871 -1 -1890 -5z">
        <Path.RenderTransform><MatrixTransform Matrix="0.1,0,0,-0.1,-410,936"/></Path.RenderTransform>
       </Path>
       <Path Fill="#008036"
             Data="M7350 7920 c-194 -7 -227 -14 -324 -61 -83 -41 -148 -99 -201 -179 -75 -113 -87 -160 -93 -346 l-4 -161 47 -17 c75 -25 128 -60 189 -126 99 -108 131 -199 124 -352 -5 -91 -8 -105 -46 -182 -60 -121 -158 -204 -295 -250 -17 -6 -18 -24 -15 -348 l3 -343 28 -79 c39 -111 98 -206 181 -293 110 -117 214 -181 373 -230 l88 -28 842 -3 842 -3 3 -149 c3 -141 4 -150 27 -174 14 -15 42 -32 63 -38 50 -15 78 -2 183 88 44 38 204 174 355 303 151 128 285 245 298 258 25 27 30 94 11 137 -6 13 -50 58 -98 98 -317 272 -640 546 -661 561 -41 29 -95 22 -138 -17 l-37 -34 -3 -151 -3 -151 -615 0 c-410 0 -630 4 -658 11 -56 14 -114 62 -137 113 -18 39 -19 91 -19 1094 l0 1052 -42 0 c-24 0 -52 2 -63 3 -11 2 -103 1 -205 -3z">
        <Path.RenderTransform><MatrixTransform Matrix="0.1,0,0,-0.1,-410,936"/></Path.RenderTransform>
       </Path>
       <Path Fill="#008036"
             Data="M6553 6970 c-80 -19 -161 -91 -189 -169 -18 -49 -17 -154 1 -197 25 -60 73 -112 130 -140 48 -23 64 -26 134 -23 73 4 83 7 137 44 82 58 119 126 118 220 0 52 -6 81 -23 113 -61 118 -188 181 -308 152z">
        <Path.RenderTransform><MatrixTransform Matrix="0.1,0,0,-0.1,-410,936"/></Path.RenderTransform>
       </Path>
      </Canvas>
     </Viewbox>
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
      <Grid.ColumnDefinitions>
       <ColumnDefinition Width="*"/>
       <ColumnDefinition Width="12"/>
       <ColumnDefinition Width="Auto"/>
       <ColumnDefinition Width="8"/>
       <ColumnDefinition Width="Auto"/>
      </Grid.ColumnDefinitions>
      <PasswordBox x:Name="ApiKeyBox" Height="42" MaxLength="500" VerticalContentAlignment="Center"/>
      <Button x:Name="VerifyButton" Grid.Column="2" Content="Verify &amp; save" MinWidth="132" Height="42"
              Style="{StaticResource PrimaryButton}"/>
      <Button x:Name="ClearKeyButton" Grid.Column="4" Content="Clear saved key" MinWidth="118" Height="42"
              Style="{StaticResource DangerButton}"/>
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
       <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="8"/>
        <ColumnDefinition Width="Auto"/>
       </Grid.ColumnDefinitions>
       <Button x:Name="CodexToggleButton" Content="Connect Codex" Height="42" Style="{StaticResource GreenButton}"/>
       <Button x:Name="OpenCodexButton" Grid.Column="2" Content="Open Codex" Height="42" MinWidth="104" Style="{StaticResource SecondaryButton}"/>
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
                 Visibility="Collapsed"/>

      <Grid Grid.Row="3" Margin="0,18,0,0">
       <Grid.ColumnDefinitions>
        <ColumnDefinition Width="*"/>
        <ColumnDefinition Width="8"/>
        <ColumnDefinition Width="Auto"/>
       </Grid.ColumnDefinitions>
       <Button x:Name="ClaudeToggleButton" Content="Connect Claude" Height="42" Style="{StaticResource BlueButton}"/>
       <Button x:Name="OpenClaudeButton" Grid.Column="2" Content="Open Claude" Height="42" MinWidth="104" Style="{StaticResource SecondaryButton}"/>
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
     <StackPanel Grid.Column="1" Orientation="Horizontal" HorizontalAlignment="Center" VerticalAlignment="Center">
      <Button x:Name="YouTubeButton" Style="{StaticResource SocialButton}" ToolTip="TunnelLab on YouTube">
       <StackPanel Orientation="Horizontal">
        <Viewbox Width="20" Height="15" Margin="0,0,7,0">
         <Path Fill="#FF3355" Data="M23.5,6.2 A3,3 0 0 0 21.4,4.1 C19.5,3.6 12,3.6 12,3.6 C12,3.6 4.5,3.6 2.6,4.1 A3,3 0 0 0 .5,6.2 A31,31 0 0 0 0,12 A31,31 0 0 0 .5,17.8 A3,3 0 0 0 2.6,19.9 C4.5,20.4 12,20.4 12,20.4 C12,20.4 19.5,20.4 21.4,19.9 A3,3 0 0 0 23.5,17.8 A31,31 0 0 0 24,12 A31,31 0 0 0 23.5,6.2 Z M9.6,15.6 L9.6,8.4 L15.8,12 Z"/>
        </Viewbox>
        <TextBlock Text="YouTube" VerticalAlignment="Center"/>
       </StackPanel>
      </Button>
      <Button x:Name="GitHubButton" Style="{StaticResource SocialButton}" Margin="7,0,0,0" ToolTip="GitHub">
       <StackPanel Orientation="Horizontal">
        <Viewbox Width="17" Height="17" Margin="0,0,7,0">
         <Path Fill="#D7E0EB" Data="M12,.7 A11.5,11.5 0 0 0 8.36,23.11 C8.94,23.21 9.15,22.86 9.15,22.55 L9.15,20.39 C5.92,21.09 5.24,19.02 5.24,19.02 C4.71,17.68 3.95,17.32 3.95,17.32 C2.9,16.6 4.03,16.62 4.03,16.62 C5.19,16.7 5.81,17.82 5.81,17.82 C6.85,19.59 8.53,19.08 9.2,18.78 C9.3,18.03 9.6,17.52 9.94,17.23 C7.36,16.94 4.64,15.94 4.64,11.48 C4.64,10.21 5.1,9.17 5.84,8.35 C5.72,8.05 5.32,6.87 5.96,5.26 C5.96,5.26 6.94,4.95 9.12,6.46 A10.9,10.9 0 0 1 14.87,6.46 C17.05,4.95 18.03,5.26 18.03,5.26 C18.67,6.87 18.27,8.06 18.15,8.35 C18.9,9.17 19.35,10.21 19.35,11.48 C19.35,15.95 16.63,16.93 14.04,17.22 C14.46,17.58 14.83,18.29 14.83,19.38 L14.83,22.55 C14.83,22.86 15.04,23.22 15.63,23.11 A11.5,11.5 0 0 0 12,.7 Z"/>
        </Viewbox>
        <TextBlock Text="GitHub" VerticalAlignment="Center"/>
       </StackPanel>
      </Button>
      <Button x:Name="WebsiteButton" Style="{StaticResource SocialButton}" Margin="7,0,0,0" ToolTip="pouramin.dev">
       <StackPanel Orientation="Horizontal">
        <Border Width="20" Height="20" CornerRadius="5" Background="#5749E8" Margin="0,0,7,0">
         <TextBlock Text="AP" Foreground="White" FontSize="7.5" FontWeight="Bold" HorizontalAlignment="Center" VerticalAlignment="Center"/>
        </Border>
        <TextBlock Text="Website" VerticalAlignment="Center"/>
       </StackPanel>
      </Button>
     </StackPanel>
     <Button x:Name="RefreshButton" Grid.Column="2" Content="Refresh status" Height="34" Padding="12,6" Style="{StaticResource SecondaryButton}" FontSize="10.5"/>
     <Button x:Name="ResetButton" Grid.Column="4" Content="Reset JEV" Height="34" Padding="12,6"
             Style="{StaticResource DangerButton}" FontSize="10.5"
             ToolTip="Restore Codex defaults and remove TypeSafe/Jev credentials saved by this app."/>
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

$ApiKeyBox=C 'ApiKeyBox'; $VerifyButton=C 'VerifyButton'; $ClearKeyButton=C 'ClearKeyButton'; $KeyStatus=C 'KeyStatus'
$GlobalDot=C 'GlobalDot'; $GlobalStatus=C 'GlobalStatus'
$CodexDetection=C 'CodexDetection'; $CodexBridgeStatus=C 'CodexBridgeStatus'
$ClaudeDetection=C 'ClaudeDetection'; $ClaudePluginStatus=C 'ClaudePluginStatus'
$CodexToggleButton=C 'CodexToggleButton'; $OpenCodexButton=C 'OpenCodexButton'
$ClaudeToggleButton=C 'ClaudeToggleButton'; $OpenClaudeButton=C 'OpenClaudeButton'
$YouTubeButton=C 'YouTubeButton'; $GitHubButton=C 'GitHubButton'; $WebsiteButton=C 'WebsiteButton'
$RefreshButton=C 'RefreshButton'; $ResetButton=C 'ResetButton'; $FooterStatus=C 'FooterStatus'; $ClaudeInstructions=C 'ClaudeInstructions'

$script:Busy=$false
$script:ActivePowerShell=$null
$script:ActiveAsync=$null
$script:Timer=New-Object Windows.Threading.DispatcherTimer
$script:Timer.Interval=[TimeSpan]::FromMilliseconds(400)

function Busy([bool]$Value,[string]$Message='Working...') {
 foreach($x in @($VerifyButton,$ClearKeyButton,$CodexToggleButton,$OpenCodexButton,$ClaudeToggleButton,$OpenClaudeButton,$YouTubeButton,$GitHubButton,$WebsiteButton,$RefreshButton,$ResetButton)){ $x.IsEnabled=-not $Value }
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

  $script:CodexConnected=[bool]$s.CodexBridge
  $CodexToggleButton.Content=$(if($script:CodexConnected){'Disconnect Codex'}else{'Connect Codex'})
  $CodexToggleButton.Style=$window.FindResource($(if($script:CodexConnected){'SecondaryButton'}else{'GreenButton'}))

  $script:ClaudeConnected=[bool]$s.ClaudePlugin
  $ClaudeToggleButton.Content=$(if($script:ClaudeConnected){'Disconnect Claude'}else{'Connect Claude'})
  $ClaudeToggleButton.Style=$window.FindResource($(if($script:ClaudeConnected){'SecondaryButton'}else{'BlueButton'}))

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
 } elseif($Name -eq 'Disconnect Claude'){
  $result=Remove-ClaudeIntegration
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
 elseif($result -and $result.Action -eq 'Disconnect Claude'){
  $ClaudeInstructions.Text='Claude integration removed. Restart Claude Desktop to refresh plugin state.'
  $FooterStatus.Text='Claude integration removed.'
  [Windows.MessageBox]::Show($window,"Jev Model Router was removed from Claude where possible. Restart Claude Desktop to refresh the plugin list.",'Claude disconnected','OK','Information')|Out-Null
 }
 elseif($result -and $result.Action -eq 'Disconnect Codex'){
  [Windows.MessageBox]::Show($window,"Jev Router was removed from Codex configuration. Restart Codex Desktop to refresh the model list.",'Codex disconnected','OK','Information')|Out-Null
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

$ClearKeyButton.Add_Click({
 if(-not(Get-SavedTypeSafeKey)){Refresh-Ui;return}
 $msg='Forget the TypeSafe API key saved by Jev Router for this Windows user? Existing Codex or Claude integrations can keep their own configured credential until you disconnect them.'
 if([Windows.MessageBox]::Show($window,$msg,'Clear saved key','YesNo','Warning') -ne 'Yes'){return}
 try{
  Remove-SavedTypeSafeKey
  $ApiKeyBox.Password=''
  Refresh-Ui
  [Windows.MessageBox]::Show($window,'The locally saved TypeSafe key was removed.','Saved key cleared','OK','Information')|Out-Null
 }catch{Err $_.Exception.Message}
})

$CodexToggleButton.Add_Click({
 if($script:CodexConnected){
  $q='Remove Jev Router from Codex, restore the previous model selection where possible, and remove the bridge service/package?'
  if([Windows.MessageBox]::Show($window,$q,'Disconnect Codex','YesNo','Question') -eq 'Yes'){Background 'Disconnect Codex'}
  return
 }

 if(-not(Get-SavedTypeSafeKey)){Err 'Verify and save your TypeSafe API key first.';return}
 $q='This can install Git and Node.js with WinGet, install jev-codex-bridge, back up Codex configuration, and add a user-level background task. Continue?'
 if([Windows.MessageBox]::Show($window,$q,'Connect Codex','YesNo','Question') -eq 'Yes'){Background 'Connect Codex'}
})

$ClaudeToggleButton.Add_Click({
 if($script:ClaudeConnected){
  $q='Remove Jev Model Router from Claude Code, remove its marketplace entry where possible, and clear Jev/TypeSafe environment keys created for Claude?'
  if([Windows.MessageBox]::Show($window,$q,'Disconnect Claude','YesNo','Question') -eq 'Yes'){Background 'Disconnect Claude'}
  return
 }

 if(-not(Get-SavedTypeSafeKey)){Err 'Verify and save your TypeSafe API key first.';return}
 $q='This can install the official Claude Code CLI with WinGet if it is missing, add the Jev Model Router marketplace, install the plugin at user scope, and open Claude. Continue?'
 if([Windows.MessageBox]::Show($window,$q,'Connect Claude','YesNo','Question') -eq 'Yes'){Background 'Connect Claude'}
})

$OpenCodexButton.Add_Click({
 try{Start-Process 'codex://threads/new'}
 catch{
  try{Start-Process 'https://chatgpt.com/codex?app-landing-page=true'}
  catch{Err 'Codex could not be opened.'}
 }
})
$OpenClaudeButton.Add_Click({try{Start-Process 'claude://code'}catch{Err 'Claude Desktop could not be opened.'}})

$YouTubeButton.Add_Click({try{Start-Process 'https://www.youtube.com/@tunnellab'}catch{Err 'YouTube could not be opened.'}})
$GitHubButton.Add_Click({try{Start-Process 'https://github.com/pouramin'}catch{Err 'GitHub could not be opened.'}})
$WebsiteButton.Add_Click({try{Start-Process 'https://pouramin.dev/'}catch{Err 'Website could not be opened.'}})

$ResetButton.Add_Click({
 $msg='Reset everything configured by Jev Router? This restores Codex from the bridge backup when available, removes the Codex bridge, removes the Claude Jev plugin where possible, clears Jev/TypeSafe environment keys, deletes the protected TypeSafe key saved by this app, and removes Jev keys from the bridge environment file.'
 if([Windows.MessageBox]::Show($window,$msg,'Reset JEV','YesNo','Warning') -eq 'Yes'){Background 'Reset All'}
})
$RefreshButton.Add_Click({Refresh-Ui})

if($XamlTest){
 Write-Output 'XAMLTEST_OK'
 try{$window.Close()}catch{}
 exit 0
}

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
