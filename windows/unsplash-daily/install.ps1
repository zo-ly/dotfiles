# Install or update the daily Unsplash task. Re-run after every change to unsplash-daily.ps1.
#   powershell -ExecutionPolicy Bypass -File \\wsl.localhost\Ubuntu\home\zoly\dotfiles\windows\unsplash-daily\install.ps1 [-RunNow]
#
# The script is copied to %LOCALAPPDATA%: the task fires at logon, before WSL is up,
# so it must not run from \\wsl.localhost.
param([switch]$RunNow)

$ErrorActionPreference = 'Stop'

$TaskName   = 'Unsplash Daily'
$InstallDir = Join-Path $env:LOCALAPPDATA 'UnsplashDaily'
$Script     = Join-Path $InstallDir 'unsplash-daily.ps1'

if (-not [Environment]::GetEnvironmentVariable('UNSPLASH_ACCESS_KEY', 'User')) {
    $key = Read-Host 'Unsplash Access Key (unsplash.com/developers)'
    if (-not $key) { throw 'No key given' }
    [Environment]::SetEnvironmentVariable('UNSPLASH_ACCESS_KEY', $key.Trim(), 'User')
}

New-Item -ItemType Directory -Force $InstallDir | Out-Null
Copy-Item (Join-Path $PSScriptRoot 'unsplash-daily.ps1') $Script -Force

$action   = New-ScheduledTaskAction -Execute 'powershell.exe' `
    -Argument "-NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File `"$Script`""
$daily    = New-ScheduledTaskTrigger -Daily -At 8:00
$logon    = New-ScheduledTaskTrigger -AtLogOn -User "$env:USERDOMAIN\$env:USERNAME"
$logon.Delay = 'PT1M'
$settings = New-ScheduledTaskSettingsSet -StartWhenAvailable -RunOnlyIfNetworkAvailable `
    -AllowStartIfOnBatteries -DontStopIfGoingOnBatteries -ExecutionTimeLimit (New-TimeSpan -Minutes 30)
Register-ScheduledTask -TaskName $TaskName -Action $action -Trigger $daily, $logon -Settings $settings -Force | Out-Null
Write-Host "Installed $Script and scheduled task '$TaskName'."

# Desktop right-click menu: an "Unsplash" submenu to open today's photos on Unsplash
# (to like / collect them) or swap one. Windows 11 lists it under "Show more options"
# (or Shift+right-click). Rebuilt from scratch on every install.
$shell  = 'HKCU:\Software\Classes\DesktopBackground\Shell'
$photos = Join-Path $env:USERPROFILE 'Pictures\Unsplash'
foreach ($old in 'Unsplash', 'UnsplashWallpaper', 'UnsplashLockScreen') {
    Remove-Item "$shell\$old" -Recurse -Force -ErrorAction SilentlyContinue
}
$menu = "$shell\Unsplash"
New-Item -Path $menu -Force | Out-Null
New-Item -Path "$menu\shell" -Force | Out-Null
Set-ItemProperty -Path $menu -Name 'MUIVerb' -Value 'Unsplash'
Set-ItemProperty -Path $menu -Name 'SubCommands' -Value ''

$open = 'explorer.exe "{0}"'
$swap = 'powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File "{0}" -Only {1}'
# Key names sort the entries; 0x20 = separator before.
$items = @(
    @('1-open-wallpaper',  'Open this wallpaper',   ($open -f (Join-Path $photos 'Wallpaper.url')),  0),
    @('2-open-lockscreen', 'Open this lock screen', ($open -f (Join-Path $photos 'LockScreen.url')), 0),
    @('3-new-wallpaper',   'New wallpaper',         ($swap -f $Script, 'Wallpaper'),                  0x20),
    @('4-new-lockscreen',  'New lock screen',       ($swap -f $Script, 'LockScreen'),                 0)
)
foreach ($item in $items) {
    $key = "$menu\shell\$($item[0])"
    New-Item -Path $key -Force | Out-Null
    New-Item -Path "$key\command" -Force | Out-Null
    Set-ItemProperty -Path $key -Name 'MUIVerb' -Value $item[1]
    if ($item[3]) { New-ItemProperty -Path $key -Name 'CommandFlags' -PropertyType DWord -Value $item[3] -Force | Out-Null }
    Set-ItemProperty -Path "$key\command" -Name '(default)' -Value $item[2]
}
Write-Host 'Added the desktop right-click submenu "Unsplash".'

$legacy = Join-Path $env:USERPROFILE 'Scripts\unsplash-daily.ps1'
if (Test-Path $legacy) { Write-Warning "$legacy is no longer used and can be deleted." }

if ($RunNow) {
    Start-ScheduledTask -TaskName $TaskName
    Write-Host "Started. Log: $env:USERPROFILE\Pictures\Unsplash\log.txt"
}
