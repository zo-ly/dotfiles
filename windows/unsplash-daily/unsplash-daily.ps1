# Unsplash daily wallpaper + screensaver (Windows PowerShell 5.1).
#   Desktop:     one new photo per day, set directly.
#   Screensaver: a folder of photos for the built-in "Photos" screensaver,
#                replaced as a whole every day. Never overlaps the desktop photo.
#
# Runs once per day: a second run on the same day exits at once unless -Force.
# Each run costs ScreensaverCount + 3 API requests; the demo quota is 50 per hour.
# Needs the user environment variable UNSPLASH_ACCESS_KEY (install.ps1 sets it).
# Keep this file ASCII-only: PowerShell 5.1 reads BOM-less files as ANSI.
param(
    [switch]$Force,
    [string]$WallpaperQuery = 'landscape',
    [string]$ScreensaverQuery = 'nature',
    [ValidateRange(1, 30)][int]$ScreensaverCount = 20,
    [int]$Width = 3840,
    [string]$Root = (Join-Path $env:USERPROFILE 'Pictures\Unsplash')
)

$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$Key = [Environment]::GetEnvironmentVariable('UNSPLASH_ACCESS_KEY', 'User')
if (-not $Key) { throw 'UNSPLASH_ACCESS_KEY is not set' }
$Headers = @{ Authorization = "Client-ID $Key"; 'Accept-Version' = 'v1' }

$WallDir  = Join-Path $Root 'Wallpaper'
$SaverDir = Join-Path $Root 'Screensaver'
$Staging  = Join-Path $Root 'staging'
$Stamp    = Join-Path $Root 'last-run.txt'
$Log      = Join-Path $Root 'log.txt'
New-Item -ItemType Directory -Force $WallDir, $SaverDir | Out-Null

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

$sig = '[DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern bool SystemParametersInfo(int a, int p, string f, int fl);'
Add-Type -MemberDefinition $sig -Name Wallpaper -Namespace Win32

try {
    $walls = Get-RandomPhotos $WallpaperQuery 1
    $wall  = $walls[0]
    $saver = Get-RandomPhotos $ScreensaverQuery $ScreensaverCount
    $saver = $saver | Where-Object { $_.id -ne $wall.id }

    # Desktop. SPI_SETDESKWALLPAPER also switches the background type to "Picture".
    $old = Get-ChildItem $WallDir -Filter *.jpg
    $wallFile = Save-Photo $wall $WallDir 'wallpaper'
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' WallpaperStyle '10'   # fill
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' TileWallpaper '0'
    if (-not [Win32.Wallpaper]::SystemParametersInfo(0x14, 0, $wallFile, 0x3)) { throw 'SystemParametersInfo failed' }
    $old | Where-Object { $_.FullName -ne $wallFile } | Remove-Item -Force

    # Screensaver: download into staging, swap only once every photo has arrived.
    Remove-Item $Staging -Recurse -Force -ErrorAction SilentlyContinue
    New-Item -ItemType Directory $Staging | Out-Null
    foreach ($p in $saver) { Save-Photo $p $Staging 'screensaver' | Out-Null }
    Get-ChildItem $SaverDir -File | Remove-Item -Force
    Get-ChildItem $Staging -File | Move-Item -Destination $SaverDir
    Remove-Item $Staging -Force

    Set-Content -Path $Stamp -Value $today
    Write-Log 'done'
} catch {
    Write-Log "ERROR: $_"
    throw
}
