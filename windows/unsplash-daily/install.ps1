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

$legacy = Join-Path $env:USERPROFILE 'Scripts\unsplash-daily.ps1'
if (Test-Path $legacy) { Write-Warning "$legacy is no longer used and can be deleted." }

if ($RunNow) {
    Start-ScheduledTask -TaskName $TaskName
    Write-Host "Started. Log: $env:USERPROFILE\Pictures\Unsplash\log.txt"
}
