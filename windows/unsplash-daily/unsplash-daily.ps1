# Unsplash daily desktop wallpaper + lock screen (Windows PowerShell 5.1).
# Each day: one photo for the desktop, a different one for the lock screen (Win+L).
#
# Runs once per day: a second run on the same day exits at once unless -Force.
# Each run costs 4 API requests; the demo quota is 50 per hour.
# Needs the user environment variable UNSPLASH_ACCESS_KEY (install.ps1 sets it).
# Must stay on Windows PowerShell 5.1: the lock screen API is WinRT, which pwsh 7 cannot load.
# Keep this file ASCII-only: PowerShell 5.1 reads BOM-less files as ANSI.
param(
    [switch]$Force,
    # Each day two different terms are drawn: one for the desktop, one for the lock screen.
    [string[]]$Queries = @(
        # Japan
        'kyoto', 'japanese countryside', 'japanese temple', 'mount fuji', 'japan coast',
        # Yunnan / Dali
        'dali yunnan', 'erhai lake', 'yunnan', 'lijiang',
        # Same quiet mood elsewhere
        'faroe islands', 'lofoten', 'dolomites', 'misty forest', 'rice terraces', 'tea plantation'
    ),
    [int]$Width = 3840,
    [string]$Root = (Join-Path $env:USERPROFILE 'Pictures\Unsplash')
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Key = [Environment]::GetEnvironmentVariable('UNSPLASH_ACCESS_KEY', 'User')
if (-not $Key) { throw 'UNSPLASH_ACCESS_KEY is not set' }
$Headers = @{ Authorization = "Client-ID $Key"; 'Accept-Version' = 'v1' }

$WallDir = Join-Path $Root 'Wallpaper'
$LockDir = Join-Path $Root 'LockScreen'
$Stamp   = Join-Path $Root 'last-run.txt'
$Log     = Join-Path $Root 'log.txt'
New-Item -ItemType Directory -Force $WallDir, $LockDir | Out-Null

function Write-Log([string]$msg) { "$(Get-Date -Format s)  $msg" | Add-Content -Encoding UTF8 $Log }

$today = Get-Date -Format 'yyyy-MM-dd'
if (-not $Force -and (Test-Path $Stamp) -and ((Get-Content $Stamp -Raw).Trim() -eq $today)) { exit 0 }

function Get-RandomPhotos([string]$query, [int]$count) {
    $q = [uri]::EscapeDataString($query)
    $url = "https://api.unsplash.com/photos/random?count=$count&orientation=landscape&content_filter=high&query=$q"
    Invoke-RestMethod -Uri $url -Headers $Headers -UseBasicParsing
}

function Save-Photo($photo, [string]$dir, [string]$label) {
    $file = Join-Path $dir ('{0}.jpg' -f $photo.id)
    $src  = '{0}&w={1}&q=85&fm=jpg' -f $photo.urls.raw, $Width
    Invoke-WebRequest -Uri $src -OutFile $file -UseBasicParsing
    # Unsplash API guidelines: report each download
    try { Invoke-RestMethod -Uri $photo.links.download_location -Headers $Headers -UseBasicParsing | Out-Null } catch {}
    Write-Log ('{0}  {1}  by {2}' -f $label, $photo.links.html, $photo.user.name)
    $file
}

# <name>.url opens the photo's Unsplash page; the desktop right-click menu (install.ps1) points here.
function Write-PageShortcut([string]$name, $photo) {
    $url = '{0}?utm_source=unsplash_daily&utm_medium=referral' -f $photo.links.html
    Set-Content -Path (Join-Path $Root "$name.url") -Value "[InternetShortcut]`r`nURL=$url" -Encoding ASCII
}

# Keep only the photo just set; Windows has already copied it into its own store.
function Remove-Older([string]$dir, [string]$keep) {
    Get-ChildItem $dir -Filter *.jpg | Where-Object { $_.FullName -ne $keep } | Remove-Item -Force
}

function Set-Wallpaper([string]$file) {
    $sig = '[DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern bool SystemParametersInfo(int a, int p, string f, int fl);'
    Add-Type -MemberDefinition $sig -Name Wallpaper -Namespace Win32
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' WallpaperStyle '10'   # fill
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' TileWallpaper '0'
    # SPI_SETDESKWALLPAPER, persist + broadcast; also switches the background type to "Picture"
    if (-not [Win32.Wallpaper]::SystemParametersInfo(0x14, 0, $file, 0x3)) { throw 'SystemParametersInfo failed' }
}

function Set-LockScreen([string]$file) {
    Add-Type -AssemblyName System.Runtime.WindowsRuntime
    $null = [Windows.Storage.StorageFile,Windows.Storage,ContentType=WindowsRuntime]
    $null = [Windows.System.UserProfile.LockScreen,Windows.System.UserProfile,ContentType=WindowsRuntime]
    $asTask = [System.WindowsRuntimeSystemExtensions].GetMethods() |
        Where-Object { $_.Name -eq 'AsTask' -and $_.GetParameters().Count -eq 1 }
    $opAsTask  = ($asTask | Where-Object { $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncOperation`1' })[0]
    $actAsTask = ($asTask | Where-Object { $_.GetParameters()[0].ParameterType.Name -eq 'IAsyncAction' })[0]

    $getFile = $opAsTask.MakeGenericMethod([Windows.Storage.StorageFile]).Invoke(
        $null, @([Windows.Storage.StorageFile]::GetFileFromPathAsync($file)))
    $getFile.Wait(-1) | Out-Null
    $setImage = $actAsTask.Invoke($null, @([Windows.System.UserProfile.LockScreen]::SetImageFileAsync($getFile.Result)))
    $setImage.Wait(-1) | Out-Null
}

try {
    $picked    = @($Queries | Get-Random -Count 2)
    $wallQuery = $picked[0]
    $lockQuery = if ($picked.Count -gt 1) { $picked[1] } else { $picked[0] }
    Write-Log "queries: desktop '$wallQuery', lock screen '$lockQuery'"

    $walls = Get-RandomPhotos $wallQuery 1
    $wall  = $walls[0]
    # Ask for two so one is left even if the first matches the desktop photo.
    $locks = Get-RandomPhotos $lockQuery 2
    $lock  = $null
    foreach ($p in $locks) { if ($p.id -ne $wall.id) { $lock = $p; break } }

    $wallFile = Save-Photo $wall $WallDir 'wallpaper'
    Set-Wallpaper $wallFile
    Write-PageShortcut 'Wallpaper' $wall
    Remove-Older $WallDir $wallFile

    $lockFile = Save-Photo $lock $LockDir 'lockscreen'
    Set-LockScreen $lockFile
    Write-PageShortcut 'LockScreen' $lock
    Remove-Older $LockDir $lockFile

    Set-Content -Path $Stamp -Value $today
    Write-Log 'done'
} catch {
    Write-Log "ERROR: $_"
    throw
}
