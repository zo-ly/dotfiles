# Daily desktop wallpaper + lock screen from Unsplash and Wallhaven (Windows PowerShell 5.1).
# Each day: one photo for the desktop, a different one for the lock screen (Win+L).
#
# Runs once per day: a second run on the same day exits at once unless -Force.
# -Only Wallpaper / -Only LockScreen swaps just that photo, at any time (desktop right-click menu).
# Photos are downloaded at full size, converted to sRGB; anything narrower than -MinWidth is
# skipped, and search / topic results uploaded before -Since too. Photos never shown come
# first, then the one shown longest ago, so a small collection cycles through all its photos.
# Unsplash: 2-3 API requests per photo, demo quota 50 per hour, needs the user env var
# UNSPLASH_ACCESS_KEY (install.ps1 sets it). Wallhaven: no key, so SFW only.
# Must stay on Windows PowerShell 5.1: the lock screen API is WinRT, which pwsh 7 cannot load.
# Keep this file ASCII-only: PowerShell 5.1 reads BOM-less files as ANSI.
param(
    [switch]$Force,
    [ValidateSet('Both', 'Wallpaper', 'LockScreen')][string]$Only = 'Both',
    # Each day two different entries are drawn: one for the desktop, one for the lock screen.
    # Entry kinds:
    #   collection:<id>  every landscape photo of an Unsplash collection (id from its URL)
    #   topic:<slug>     newest photos of an editor-curated Unsplash topic (unsplash.com/t/<slug>)
    #   wh:<term>        Wallhaven search (art and screenshots, general + anime categories)
    #   <term>           Unsplash search, most relevant first
    [string[]]$Queries = @(
        'collection:27HJMxXMC7k'
    ),
    [int]$MinWidth = 3840,
    # Unsplash's most relevant results lean on 2014-2018 photos with a faded film look.
    # Not applied to collections: those photos were picked by hand.
    [int]$Since = 2020,
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
$History = Join-Path $Root 'history.txt'   # ids shown, oldest first
$Log     = Join-Path $Root 'log.txt'
New-Item -ItemType Directory -Force $WallDir, $LockDir | Out-Null

function Write-Log([string]$msg) { "$(Get-Date -Format s)  $msg" | Add-Content -Encoding UTF8 $Log }

$today = Get-Date -Format 'yyyy-MM-dd'
if (-not $Force -and $Only -eq 'Both' -and (Test-Path $Stamp) -and ((Get-Content $Stamp -Raw).Trim() -eq $today)) { exit 0 }

# Every source returns the same shape: Id (file name), Ext, Image (download URL),
# Page (web page), Width, Year (upload year, $null = don't filter), Credit, Track (Unsplash only)

function ConvertFrom-Unsplash($p) {
    [pscustomobject]@{
        Id     = $p.id
        Ext    = 'jpg'
        # raw without w/h = original size. cs=srgb: many originals carry an Adobe RGB
        # profile that the wallpaper renderer ignores, which washes the colours out.
        Image  = '{0}&fm=jpg&q=95&cs=srgb' -f $p.urls.raw
        Page   = '{0}?utm_source=unsplash_daily&utm_medium=referral' -f $p.links.html
        Width  = $p.width
        Year   = [int]$p.created_at.Substring(0, 4)
        Credit = "by $($p.user.name)"
        Track  = $p.links.download_location
    }
}

# order_by=relevant ranks good photos first; /photos/random with a query draws from the
# whole pool and returns noticeably weaker ones.
function Find-Unsplash([string]$query, [int]$page) {
    $q = [uri]::EscapeDataString($query)
    $url = "https://api.unsplash.com/search/photos?query=$q&orientation=landscape&content_filter=high" +
        "&order_by=relevant&per_page=30&page=$page"
    foreach ($p in (Invoke-RestMethod -Uri $url -Headers $Headers -UseBasicParsing).results) {
        ConvertFrom-Unsplash $p
    }
}

# The whole collection, whatever $page asks for: collections are small, and the
# never-shown / longest-ago rule needs to see every photo.
function Find-UnsplashCollection([string]$id) {
    for ($page = 1; $page -le 10; $page++) {
        $url = "https://api.unsplash.com/collections/$id/photos?orientation=landscape&per_page=30&page=$page"
        # No @() here: 5.1 emits a JSON array as one object, and @() would nest it.
        $batch = Invoke-RestMethod -Uri $url -Headers $Headers -UseBasicParsing
        foreach ($p in $batch) {
            $photo = ConvertFrom-Unsplash $p
            $photo.Year = $null
            $photo
        }
        if ($batch.Count -lt 30) { break }
    }
}

function Find-UnsplashTopic([string]$slug, [int]$page) {
    $url = "https://api.unsplash.com/topics/$slug/photos?orientation=landscape&order_by=latest" +
        "&per_page=30&page=$page"
    foreach ($p in (Invoke-RestMethod -Uri $url -Headers $Headers -UseBasicParsing)) {
        ConvertFrom-Unsplash $p
    }
}

# categories=110: general + anime, no people. purity=100: SFW (the only level without a key).
function Find-Wallhaven([string]$query, [int]$page) {
    $q = [uri]::EscapeDataString($query)
    $minHeight = [int]($MinWidth * 9 / 16)
    $url = "https://wallhaven.cc/api/v1/search?q=$q&categories=110&purity=100" +
        "&atleast=${MinWidth}x$minHeight&sorting=favorites&page=$page"
    foreach ($w in (Invoke-RestMethod -Uri $url -UseBasicParsing).data) {
        if ($w.dimension_x -le $w.dimension_y) { continue }   # landscape only
        [pscustomobject]@{
            Id     = "wh-$($w.id)"
            Ext    = [IO.Path]::GetExtension($w.path).TrimStart('.')
            Image  = $w.path
            Page   = $w.url
            Width  = $w.dimension_x
            Year   = $null   # upload date says nothing about the art's age
            Credit = 'on Wallhaven'
            Track  = $null
        }
    }
}

function Find-Photos([string]$entry, [int]$page) {
    if ($entry -like 'wh:*') { Find-Wallhaven $entry.Substring(3).Trim() $page }
    elseif ($entry -like 'topic:*') { Find-UnsplashTopic $entry.Substring(6).Trim() $page }
    elseif ($entry -like 'collection:*') { Find-UnsplashCollection $entry.Substring(11).Trim() }
    else { Find-Unsplash $entry $page }
}

function Save-Photo($photo, [string]$dir, [string]$label) {
    $file = Join-Path $dir ('{0}.{1}' -f $photo.Id, $photo.Ext)
    Invoke-WebRequest -Uri $photo.Image -OutFile $file -UseBasicParsing
    # Unsplash API guidelines: report each download
    if ($photo.Track) {
        try { Invoke-RestMethod -Uri $photo.Track -Headers $Headers -UseBasicParsing | Out-Null } catch {}
    }
    Write-Log ('{0}  {1}  {2}' -f $label, $photo.Page, $photo.Credit)
    $file
}

# <name>.url opens the photo's web page; the desktop right-click menu (install.ps1) points here.
function Write-PageShortcut([string]$name, $photo) {
    Set-Content -Path (Join-Path $Root "$name.url") -Value "[InternetShortcut]`r`nURL=$($photo.Page)" -Encoding ASCII
}

# Keep only the photo just set; Windows has already copied it into its own store.
function Remove-Older([string]$dir, [string]$keep) {
    Get-ChildItem $dir -File | Where-Object { $_.FullName -ne $keep } | Remove-Item -Force
}

function Set-Wallpaper([string]$file) {
    $sig = '[DllImport("user32.dll", CharSet = CharSet.Unicode)] public static extern bool SystemParametersInfo(int a, int p, string f, int fl);'
    Add-Type -MemberDefinition $sig -Name Wallpaper -Namespace Win32
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' WallpaperStyle '10'   # fill
    Set-ItemProperty 'HKCU:\Control Panel\Desktop' TileWallpaper '0'
    # Windows re-encodes a JPEG wallpaper at quality 85 unless told otherwise
    New-ItemProperty 'HKCU:\Control Panel\Desktop' -Name JPEGImportQuality -PropertyType DWord -Value 100 -Force | Out-Null
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

# Wide enough, recent enough, and on neither surface right now: a swap never brings back
# the photo it replaces, and the desktop and lock screen never match.
function Select-Usable($photos, $current) {
    @($photos | Where-Object {
        $_.Width -ge $MinWidth -and $current -notcontains $_.Id -and ($null -eq $_.Year -or $_.Year -ge $Since)
    })
}

function Get-History { if (Test-Path $History) { Get-Content $History | Where-Object { $_ } } }

function Add-History([string]$id) {
    $ids = @(@(Get-History) | Where-Object { $_ -ne $id }) + $id
    $ids | Select-Object -Last 500 | Set-Content -Path $History -Encoding ASCII
}

# Candidates come from one of the first five result pages, falling back to page 1 when that
# page is empty or has nothing usable. Among them: a random never-shown photo if any is
# left, else the one shown longest ago.
function Get-NewPhoto([string]$entry) {
    $current = @(Get-ChildItem $WallDir, $LockDir -File | ForEach-Object { $_.BaseName })
    $ok = Select-Usable @(Find-Photos $entry (Get-Random -Minimum 1 -Maximum 6)) $current
    if ($ok.Count -eq 0) { $ok = Select-Usable @(Find-Photos $entry 1) $current }
    if ($ok.Count -eq 0) { throw "no new photo for '$entry'" }

    $shown = @(Get-History)
    $fresh = @($ok | Where-Object { $shown -notcontains $_.Id })
    if ($fresh.Count -gt 0) { return $fresh | Get-Random }
    $ok | Sort-Object { [array]::IndexOf($shown, $_.Id) } | Select-Object -First 1
}

function Update-Surface([string]$surface, [string]$entry) {
    Write-Log "$surface  query '$entry'"
    $dir   = if ($surface -eq 'Wallpaper') { $WallDir } else { $LockDir }
    $photo = Get-NewPhoto $entry
    $file  = Save-Photo $photo $dir $surface.ToLower()
    if ($surface -eq 'Wallpaper') { Set-Wallpaper $file } else { Set-LockScreen $file }
    Write-PageShortcut $surface $photo
    Add-History $photo.Id
    Remove-Older $dir $file
}

try {
    if ($Only -eq 'Both') {
        $picked = @($Queries | Get-Random -Count 2)
        Update-Surface 'Wallpaper' $picked[0]
        Update-Surface 'LockScreen' $picked[-1]
        Set-Content -Path $Stamp -Value $today
    } else {
        Update-Surface $Only ($Queries | Get-Random)
    }
    Write-Log 'done'
} catch {
    Write-Log "ERROR: $_"
    throw
}
