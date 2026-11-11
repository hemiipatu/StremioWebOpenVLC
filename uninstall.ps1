<#
.SYNOPSIS
    Removes the custom VLC protocol handler and resets Chrome/Edge browser policies.
.NOTES
    Must be run as Administrator.
#>

# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator! Please re-launch PowerShell as Administrator."
    exit 1
}

Write-Host "[+] Removing 'vlc://' protocol registry key..." -ForegroundColor Cyan

$hkcrVlc = "Registry::HKEY_CLASSES_ROOT\VLC"

if (Test-Path $hkcrVlc) {
    Remove-Item -Path $hkcrVlc -Recurse -Force -ErrorAction SilentlyContinue
    Write-Host "    Removed registry key: $hkcrVlc" -ForegroundColor Green
}

Write-Host "[+] Cleaning up AutoLaunchProtocolsFromOrigins browser policies..." -ForegroundColor Cyan

$browserPolicyKeys = @(
    "HKLM:\SOFTWARE\Policies\Google\Chrome",
    "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
)

foreach ($keyPath in $browserPolicyKeys) {
    if (Test-Path $keyPath) {
        Remove-ItemProperty -Path $keyPath -Name "AutoLaunchProtocolsFromOrigins" -ErrorAction SilentlyContinue
        Write-Host "    Removed AutoLaunchProtocolsFromOrigins from: $keyPath" -ForegroundColor Green
    }
}

Write-Host "[+] Deleting vlc-wrapper.ps1 script..." -ForegroundColor Cyan

$vlcPaths = @(
    "${env:ProgramFiles}\VideoLAN\VLC\vlc-wrapper.ps1",
    "${env:ProgramFiles(x86)}\VideoLAN\VLC\vlc-wrapper.ps1"
)

foreach ($file in $vlcPaths) {
    if (Test-Path $file) {
        Remove-Item -Path $file -Force -ErrorAction SilentlyContinue
        Write-Host "    Deleted file: $file" -ForegroundColor Green
    }
}

Write-Host "`n[SUCCESS] Cleanup complete! Custom VLC protocol and policy configurations have been removed." -ForegroundColor DarkGreen