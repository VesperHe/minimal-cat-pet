[CmdletBinding()]
param()

$ErrorActionPreference = "Stop"
$createdNew = $false
$mutex = [System.Threading.Mutex]::new($true, "Local\MinimalCatPet", [ref]$createdNew)

if (-not $createdNew) {
    exit 0
}

try {
    Add-Type -AssemblyName PresentationFramework
    Add-Type -AssemblyName PresentationCore
    Add-Type -AssemblyName WindowsBase

    $scriptRoot = Split-Path -Parent $MyInvocation.MyCommand.Path
    $settingsDirectory = Join-Path $env:LOCALAPPDATA "MinimalCatPet"
    $settingsPath = Join-Path $settingsDirectory "settings.json"

    [xml]$xaml = @"
<Window xmlns="http://schemas.microsoft.com/winfx/2006/xaml/presentation"
        xmlns:x="http://schemas.microsoft.com/winfx/2006/xaml"
        Title="猫咪桌宠"
        Width="170"
        Height="150"
        WindowStyle="None"
        AllowsTransparency="True"
        Background="Transparent"
        ResizeMode="NoResize"
        ShowInTaskbar="False"
        Topmost="True"
        SnapsToDevicePixels="True">
    <Grid Background="Transparent">
        <Image x:Name="PetImage"
               Stretch="Uniform"
               RenderOptions.BitmapScalingMode="NearestNeighbor"
               SnapsToDevicePixels="True" />
    </Grid>
</Window>
"@

    $reader = New-Object System.Xml.XmlNodeReader $xaml
    $window = [System.Windows.Markup.XamlReader]::Load($reader)
    $petImage = $window.FindName("PetImage")

    function Load-Bitmap([string]$path) {
        $bitmap = [System.Windows.Media.Imaging.BitmapImage]::new()
        $bitmap.BeginInit()
        $bitmap.CacheOption = [System.Windows.Media.Imaging.BitmapCacheOption]::OnLoad
        $bitmap.UriSource = [System.Uri]::new($path, [System.UriKind]::Absolute)
        $bitmap.EndInit()
        $bitmap.Freeze()
        return $bitmap
    }

    $frames = @(
        (Load-Bitmap (Join-Path $scriptRoot "Resources\sleep_0.png")),
        (Load-Bitmap (Join-Path $scriptRoot "Resources\sleep_1.png"))
    )
    $script:frameIndex = 0
    $petImage.Source = $frames[0]

    function Save-PetPosition {
        if (-not (Test-Path $settingsDirectory)) {
            New-Item -ItemType Directory -Path $settingsDirectory -Force | Out-Null
        }

        @{
            Left = $window.Left
            Top = $window.Top
        } | ConvertTo-Json | Set-Content -LiteralPath $settingsPath -Encoding UTF8
    }

    $window.Add_Loaded({
        $virtualLeft = [System.Windows.SystemParameters]::VirtualScreenLeft
        $virtualTop = [System.Windows.SystemParameters]::VirtualScreenTop
        $virtualRight = $virtualLeft + [System.Windows.SystemParameters]::VirtualScreenWidth
        $virtualBottom = $virtualTop + [System.Windows.SystemParameters]::VirtualScreenHeight
        $left = $virtualRight - $window.Width - 24
        $top = $virtualBottom - $window.Height - 24

        if (Test-Path $settingsPath) {
            try {
                $saved = Get-Content -LiteralPath $settingsPath -Raw | ConvertFrom-Json
                $left = [double]$saved.Left
                $top = [double]$saved.Top
            } catch {
                # Ignore an invalid position file and use the default position.
            }
        }

        $window.Left = [Math]::Min([Math]::Max($left, $virtualLeft), $virtualRight - $window.Width)
        $window.Top = [Math]::Min([Math]::Max($top, $virtualTop), $virtualBottom - $window.Height)
    })

    $window.Add_MouseLeftButtonDown({
        if ($_.ButtonState -eq [System.Windows.Input.MouseButtonState]::Pressed) {
            try {
                $window.DragMove()
            } finally {
                Save-PetPosition
            }
        }
    })

    $contextMenu = New-Object System.Windows.Controls.ContextMenu
    $closeItem = New-Object System.Windows.Controls.MenuItem
    $closeItem.Header = "关闭这只猫咪"
    $closeItem.Add_Click({ $window.Close() })
    [void]$contextMenu.Items.Add($closeItem)
    $window.ContextMenu = $contextMenu

    $timer = New-Object System.Windows.Threading.DispatcherTimer
    $timer.Interval = [TimeSpan]::FromMilliseconds(800)
    $timer.Add_Tick({
        $script:frameIndex = ($script:frameIndex + 1) % $frames.Count
        $petImage.Source = $frames[$script:frameIndex]
    })
    $timer.Start()

    $window.Add_Closed({
        $timer.Stop()
        Save-PetPosition
    })

    [void]$window.ShowDialog()
} catch {
    Add-Type -AssemblyName PresentationFramework -ErrorAction SilentlyContinue
    [System.Windows.MessageBox]::Show(
        "猫咪桌宠启动失败：`n$($_.Exception.Message)",
        "猫咪桌宠",
        [System.Windows.MessageBoxButton]::OK,
        [System.Windows.MessageBoxImage]::Error
    ) | Out-Null
} finally {
    if ($createdNew) {
        [void]$mutex.ReleaseMutex()
    }
    $mutex.Dispose()
}
