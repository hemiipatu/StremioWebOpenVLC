# Stremio Web VLC Integration

> Seamlessly open streaming links from Stremio web directly in VLC Media Player on Windows.

![GitHub issues](https://img.shields.io/github/issues/hemiipatu/StremioWebOpenVLC?style=for-the-badge)
![GitHub closed issues](https://img.shields.io/github/issues-closed/hemiipatu/StremioWebOpenVLC?style=for-the-badge)
[![License: GPL v3](https://img.shields.io/badge/license-gplv3-blue.svg?style=for-the-badge)](https://www.gnu.org/licenses/gpl-3.0)
[![Maintenance](https://img.shields.io/badge/maintained%3f-yes-green.svg?style=for-the-badge)](https://github.com/hemiipatu/StremioWebOpenVLC/graphs/commit-activity)
![GitHub contributors](https://img.shields.io/github/contributors/hemiipatu/StremioWebOpenVLC?style=for-the-badge)
![GitHub commit activity](https://img.shields.io/github/commit-activity/m/hemiipatu/StremioWebOpenVLC?style=for-the-badge)

## 📋 Overview

**StremioWebOpenVLC** enables the `vlc://` protocol handler on Windows, allowing Stremio web (via Chrome or Edge) to automatically launch VLC Media Player with streaming URLs. This eliminates the need for manual copying and pasting of links or switching between applications.

### What It Does

1. **Registers the `vlc://` URL protocol** in Windows Registry
2. **Creates a protocol wrapper** that handles URL formatting and passes streams to VLC
3. **Configures Chrome and Edge browser policies** to auto-launch the VLC protocol from Stremio domains without prompting

## ⚙️ Requirements

- **Windows 10 or 11**
- **VLC Media Player** installed (standard installation paths supported)
- **Administrator privileges** to run the installation script
- **Chrome or Edge browser** (or both) configured to access Stremio web

## 🚀 Quick Start

### Installation

1. **Clone or download** this repository to your local machine. To clone it with Git:
   ```powershell
   git clone https://github.com/hemiipatu/StremioWebOpenVLC.git
   ```
2. **Open PowerShell as Administrator**
   - Right-click PowerShell and select "Run as Administrator"
3. **Navigate** to the downloaded repository directory:
   ```powershell
   Set-Location "C:\path\to\StremioWebOpenVLC"
   ```
4. **Run the installer:**
   ```powershell
   .\install.ps1
   ```
5. **Reload browser policies** (optional but recommended):
   - Chrome: Navigate to `chrome://policy` and click "Reload policies"
   - Edge: Navigate to `edge://policy` and click "Reload policies"

### Uninstallation

To remove the VLC protocol handler and restore default settings:

1. **Open PowerShell as Administrator**
2. **Navigate** to the repository directory
3. **Run the uninstaller:**
   ```powershell
   .\uninstall.ps1
   ```

## 🏗️ Architecture Diagram

```
Stremio Web (Chrome/Edge)
        ↓
vlc:// link clicked
        ↓
Browser Policy (AutoLaunchProtocolsFromOrigins)
        ↓
Windows Registry (HKEY_CLASSES_ROOT\VLC)
        ↓
MSHTA.exe executes vlc-wrapper.ps1
        ↓
vlc-wrapper.ps1 cleans the URL
        ↓
VLC Media Player opens with the stream
```

## 📁 Directory Structure

```text
StremioWebOpenVLC/
├── browser-policies.reg
├── install.ps1
├── INSTALLATION_GUIDE.md
├── LICENSE
├── README.md
├── uninstall.ps1
└── vlc-wrapper.ps1
```

## 🧩 Components

### `install.ps1` - Main Installation Script
- Locates VLC installation automatically
- Deploys `vlc-wrapper.ps1` to VLC's program directory
- Registers the `vlc://` protocol in Windows Registry
- Configures Chrome and Edge browser policies
- Handles both 32-bit and 64-bit VLC installations

### `vlc-wrapper.ps1` - Protocol Handler
- Receives the raw URL from the browser
- Strips the `vlc://` protocol prefix
- Repairs `http//` and `https//` URL formatting
- Launches VLC with the cleaned URL

### `browser-policies.reg` - Registry File
- Alternative installation method for registry entries
- Can be imported directly using Registry Editor
- Includes policies for Chrome and Edge
- Requires manual wrapper deployment and a matching VLC path

### `uninstall.ps1` - Cleanup Script
- Removes the `vlc://` protocol registry entries
- Deletes browser auto-launch policies
- Removes the wrapper script from standard VLC directories
- Removes this tool's browser policy value

## 🔧 Configuration

### Supported Stremio Domains

The following Stremio domains are whitelisted in browser policies:
- `https://stremio.com`
- `https://web.stremio.com`
- `https://strem.io`
- `https://app.strem.io`

To add additional domains, edit the browser policy in:
- Chrome: `HKLM:\SOFTWARE\Policies\Google\Chrome` - `AutoLaunchProtocolsFromOrigins`
- Edge: `HKLM:\SOFTWARE\Policies\Microsoft\Edge` - `AutoLaunchProtocolsFromOrigins`

### Modifying the VLC Path

The installer checks the standard 64-bit and 32-bit Program Files locations. To use a custom VLC location:

1. Edit the `$vlcPaths` list in `install.ps1` and add the full path to `vlc.exe`.
2. Run `install.ps1` again as Administrator. The installer writes the resolved VLC path into the deployed wrapper.

If VLC is installed outside the standard directories, `uninstall.ps1` will not find the deployed wrapper automatically; remove that copy from the custom VLC directory after uninstalling.

### Registry Details

The installer creates the following protocol registration:

```
HKEY_CLASSES_ROOT\VLC
  (Default)               = "URL:VLC Protocol"
  URL Protocol            = "" (empty string)
  shell\open\command      = MSHTA invocation of vlc-wrapper.ps1
```

Chrome and Edge receive an `AutoLaunchProtocolsFromOrigins` policy containing the allowed origins and the `vlc` protocol. The matching registry paths are:

- `HKLM:\SOFTWARE\Policies\Google\Chrome`
- `HKLM:\SOFTWARE\Policies\Microsoft\Edge`

## 🐛 Troubleshooting

### VLC not launching from Stremio

**Problem:** Clicking a stream link in Stremio doesn't open VLC

**Solutions:**
1. **Verify VLC is installed:**
   ```powershell
   Test-Path "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe"
   ```
2. **Check registry entries:**
   - Open Registry Editor (`regedit`)
   - Navigate to `HKEY_CLASSES_ROOT\VLC`
   - Verify the key and subkeys exist
3. **Reload browser policies:**
   - Chrome: Go to `chrome://policy` → "Reload policies"
   - Edge: Go to `edge://policy` → "Reload policies"
4. **Restart your browser** after installation

### "Must be run as Administrator" error

**Problem:** Script exits with admin error

**Solution:** Right-click PowerShell → "Run as Administrator" → Run script again

### Custom VLC installation not found

**Problem:** Script can't locate VLC despite it being installed

**Solution:** 
1. Manually find your VLC installation path
2. Add your custom path to `$vlcPaths` in `install.ps1`
3. Run `install.ps1` again

### Browser policy not applying

**Problem:** Policy set but browser still prompts for protocol handler

**Solutions:**
1. **Restart the browser** completely (close all windows)
2. **Check Group Policy** if using Windows Enterprise (policies might override)
3. **Verify the policy JSON** is correctly formatted
4. **Use `gpupdate /force`** in Command Prompt (admin):
   ```cmd
   gpupdate /force
   ```

## 🔒 Security

- **Administrator required:** Installation modifies system registry and writes to the VLC installation directory.
- **Browser origins:** The configured browser policy allows listed Stremio origins to auto-launch the `vlc` protocol. Add only origins you trust.
- **URL handling:** The wrapper removes the `vlc://` prefix and repairs a couple of URL schemes; it does not validate or sanitize URLs.

## 📚 File Reference

| File | Purpose |
| --- | --- |
| [`install.ps1`](./install.ps1) | Registers the protocol, deploys the wrapper, and configures Chrome and Edge policies. |
| [`uninstall.ps1`](./uninstall.ps1) | Removes the protocol registration, policy values, and wrappers in standard VLC directories. |
| [`vlc-wrapper.ps1`](./vlc-wrapper.ps1) | Cleans the incoming protocol URL and launches VLC. |
| [`browser-policies.reg`](./browser-policies.reg) | Optional registry file for manual protocol and browser policy setup. |
| [`INSTALLATION_GUIDE.md`](./INSTALLATION_GUIDE.md) | Detailed installation, verification, configuration, and troubleshooting guide. |
| [`LICENSE`](./LICENSE) | GNU General Public License, version 3. |
| [`README.md`](./README.md) | Project overview and quick reference. |

## 📄 License

This project is licensed under the **GNU General Public License v3.0 (GPL-3.0)**. See [`LICENSE`](./LICENSE) for the complete license text.

## 🤝 Contributing

To report issues or suggest improvements:

1. **Check existing issues:** [https://github.com/hemiipatu/StremioWebOpenVLC/issues](https://github.com/hemiipatu/StremioWebOpenVLC/issues)
2. **Submit a new issue:** [https://github.com/hemiipatu/StremioWebOpenVLC/issues/new](https://github.com/hemiipatu/StremioWebOpenVLC/issues/new)
3. **Provide details:**
   - Windows edition and version
   - VLC version and installation path
   - Browser and version
   - Script used (`install.ps1`, `uninstall.ps1`, or `vlc-wrapper.ps1`)
   - Error message or unexpected behavior
   - Steps to reproduce

## 🔗 Related Resources

- [Stremio Official Website](https://www.stremio.com/)
- [VLC Media Player](https://www.videolan.org/vlc/)
- [Windows Protocol Handlers](https://learn.microsoft.com/en-us/windows/win32/lwef/-search-2x-wds-ph-install-registration)
- [Chrome Auto-Launch Protocol Policy](https://chromedriver.chromium.org/security-considerations)
- [Edge Policy Reference](https://docs.microsoft.com/en-us/deployedge/microsoft-edge-policies)

---

**Last Updated:** November 2026
