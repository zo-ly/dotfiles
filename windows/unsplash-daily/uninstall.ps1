# Remove the daily Unsplash task and its installed script.
#   powershell -ExecutionPolicy Bypass -File \\wsl.localhost\Ubuntu\home\zoly\dotfiles\windows\unsplash-daily\uninstall.ps1
#
# Left in place on purpose: the photos, the UNSPLASH_ACCESS_KEY user variable,
# and the current wallpaper / lock screen.
$ErrorActionPreference = 'Stop'

$TaskName = 'Unsplash Daily'
if (Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue) {
    Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
}
Remove-Item (Join-Path $env:LOCALAPPDATA 'UnsplashDaily') -Recurse -Force -ErrorAction SilentlyContinue
foreach ($name in 'Unsplash', 'UnsplashWallpaper', 'UnsplashLockScreen') {
    Remove-Item "HKCU:\Software\Classes\DesktopBackground\Shell\$name" -Recurse -Force -ErrorAction SilentlyContinue
}

Write-Host "Removed task '$TaskName', the desktop right-click entries and $env:LOCALAPPDATA\UnsplashDaily."
Write-Host "Still there: $env:USERPROFILE\Pictures\Unsplash and the UNSPLASH_ACCESS_KEY user variable."
