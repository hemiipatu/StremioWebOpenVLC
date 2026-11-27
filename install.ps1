<#
.SYNOPSIS
    Installs the custom VLC protocol handler for Stremio and configures browser policies.
.NOTES
    Must be run as Administrator.
#>

# Ensure script is running as Administrator
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Error "This script must be run as Administrator! Please re-launch PowerShell as Administrator."
    exit 1
}

Write-Host "[+] Locating VLC Media Player..." -ForegroundColor Cyan

# Locate vlc.exe dynamically across standard installation directories
$vlcPaths = @(
    "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe",
    "${env:ProgramFiles(x86)}\VideoLAN\VLC\vlc.exe"
)

$vlcExe = $vlcPaths | Where-Object { Test-Path $_ } | Select-Object -First 1

if (-not $vlcExe) {
    Write-Error "[-] Could not locate vlc.exe in standard Program Files directories."
    exit 1
}

Write-Host "    Found VLC at: $vlcExe" -ForegroundColor Green

# Define installation target path for wrapper
$installDir = Split-Path -Path $vlcExe -Parent
$wrapperPath = Join-Path -Path $installDir -ChildPath "vlc-wrapper.ps1"

Write-Host "[+] Deploying vlc-wrapper.ps1 to $wrapperPath..." -ForegroundColor Cyan

# Create vlc-wrapper.ps1 content
$wrapperContent = @"
param([string]`$rawUrl)

if (`$rawUrl) {
    # Clean protocol scheme and repair malformed URL colons
    `$cleanUrl = `$rawUrl -replace '^vlc://', ''
    `$cleanUrl = `$cleanUrl -replace '^https//', 'https://'
    `$cleanUrl = `$cleanUrl -replace '^http//', 'http://'

    `$vlcPath = "$vlcExe"
    if (Test-Path `$vlcPath) {
        Start-Process -FilePath `$vlcPath -ArgumentList "`"`$cleanUrl`"" -WindowStyle Normal
    }
}
"@

Set-Content -Path $wrapperPath -Value $wrapperContent -Encoding UTF8
Write-Host "    vlc-wrapper.ps1 created successfully." -ForegroundColor Green

# Register vlc:// URL Protocol in HKEY_CLASSES_ROOT
Write-Host "[+] Registering 'vlc://' custom URL protocol..." -ForegroundColor Cyan

$hkcrVlc = "Registry::HKEY_CLASSES_ROOT\VLC"
$hkcrCommand = "$hkcrVlc\shell\open\command"

New-Item -Path $hkcrVlc -Force | Out-Null
Set-ItemProperty -Path $hkcrVlc -Name "(default)" -Value "URL:VLC Protocol"
Set-ItemProperty -Path $hkcrVlc -Name "URL Protocol" -Value ""

# Prepare MSHTA invocation string for silent execution
$mshtaCmd = 'mshta.exe vbscript:Execute("CreateObject(""WScript.Shell"").Run ""powershell.exe -NoProfile -ExecutionPolicy Bypass -WindowStyle Hidden -File """"{0}"""" """"%1"""""", 0, False:close")' -f $wrapperPath

New-Item -Path $hkcrCommand -Force | Out-Null
Set-ItemProperty -Path $hkcrCommand -Name "(default)" -Value $mshtaCmd

Write-Host "    vlc:// protocol registered successfully." -ForegroundColor Green

# Apply AutoLaunchProtocolsFromOrigins policy for Chrome and Edge
Write-Host "[+] Configuring browser auto-launch policies..." -ForegroundColor Cyan

$policyJson = '[{"allowed_origins":["https://web.stremio.com","https://stremio.com","https://strem.io","https://app.strem.io"],"protocol":"vlc"}]'

$browserPolicyKeys = @(
    "HKLM:\SOFTWARE\Policies\Google\Chrome",
    "HKLM:\SOFTWARE\Policies\Microsoft\Edge"
)

$stremioOrigins = @(
    "https://web.stremio.com",
    "https://stremio.com",
    "https://strem.io",
    "https://app.strem.io"
)

foreach ($keyPath in $browserPolicyKeys) {
    if (-not (Test-Path $keyPath)) {
        New-Item -Path $keyPath -Force | Out-Null
    }

    $policyEntries = @()
    $existingPolicy = Get-ItemProperty -Path $keyPath -Name "AutoLaunchProtocolsFromOrigins" -ErrorAction SilentlyContinue

    if ($null -ne $existingPolicy -and $null -ne $existingPolicy.AutoLaunchProtocolsFromOrigins) {
        try {
            $existingEntries = $existingPolicy.AutoLaunchProtocolsFromOrigins | ConvertFrom-Json
            if ($null -ne $existingEntries) {
                $policyEntries = @($existingEntries)
            }
        } catch {
            Write-Error "Existing AutoLaunchProtocolsFromOrigins policy at $keyPath is invalid JSON. Installation stopped to avoid overwriting it."
            exit 1
        }
    }

    $vlcEntry = $policyEntries | Where-Object { $_.protocol -eq "vlc" } | Select-Object -First 1

    if ($null -ne $vlcEntry) {
        $allowedOrigins = @($vlcEntry.allowed_origins)
        foreach ($origin in $stremioOrigins) {
            if ($allowedOrigins -notcontains $origin) {
                $allowedOrigins += $origin
            }
        }
        $vlcEntry.allowed_origins = @($allowedOrigins)
    } else {
        $policyEntries += [PSCustomObject]@{
            allowed_origins = $stremioOrigins
            protocol = "vlc"
        }
    }

    # -InputObject keeps a single entry as a JSON array, which the browsers require
    $policyJson = ConvertTo-Json -InputObject @($policyEntries) -Compress -Depth 4
    Set-ItemProperty -Path $keyPath -Name "AutoLaunchProtocolsFromOrigins" -Value $policyJson
    Write-Host "    Updated policy at: $keyPath" -ForegroundColor Green
}

Write-Host "`n[SUCCESS] Installation complete! Please reload policies via chrome://policy and edge://policy." -ForegroundColor DarkGreen