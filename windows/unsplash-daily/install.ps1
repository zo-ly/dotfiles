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

# Desktop right-click menu: open today's photos on Unsplash (to like / collect them).
# Windows 11 lists these under "Show more options" (or Shift+right-click).
$photos = Join-Path $env:USERPROFILE 'Pictures\Unsplash'
$menus = [ordered]@{
    UnsplashWallpaper  = @('Unsplash: this wallpaper', 'Wallpaper.url')
    UnsplashLockScreen = @('Unsplash: this lock screen', 'LockScreen.url')
}
foreach ($name in $menus.Keys) {
    $key = "HKCU:\Software\Classes\DesktopBackground\Shell\$name"
    foreach ($k in $key, "$key\command") {
        if (-not (Test-Path $k)) { New-Item -Path $k -Force | Out-Null }
    }
    Set-ItemProperty -Path $key -Name 'MUIVerb' -Value $menus[$name][0]
    Set-ItemProperty -Path "$key\command" -Name '(default)' `
        -Value ('explorer.exe "{0}"' -f (Join-Path $photos $menus[$name][1]))
}
Write-Host 'Added the desktop right-click entries.'

$legacy = Join-Path $env:USERPROFILE 'Scripts\unsplash-daily.ps1'
if (Test-Path $legacy) { Write-Warning "$legacy is no longer used and can be deleted." }

if ($RunNow) {
    Start-ScheduledTask -TaskName $TaskName
    Write-Host "Started. Log: $env:USERPROFILE\Pictures\Unsplash\log.txt"
}
