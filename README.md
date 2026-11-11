# Stremio Web VLC Integration

> Seamlessly open streaming links from Stremio web directly in VLC Media Player on Windows.

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

1. **Clone or download** this repository to your local machine
2. **Open PowerShell as Administrator**
   - Right-click PowerShell and select "Run as Administrator"
3. **Navigate** to the repository directory:
   ```powershell
   cd E:\StremioWebOpenVLC
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

## 📖 How It Works

### Architecture

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

### Key Components

#### 1. **install.ps1** - Main Installation Script
- Locates VLC installation automatically
- Deploys `vlc-wrapper.ps1` to VLC's program directory
- Registers the `vlc://` protocol in Windows Registry
- Configures Chrome and Edge browser policies
- Handles both 32-bit and 64-bit VLC installations

#### 2. **vlc-wrapper.ps1** - Protocol Handler
- Receives the raw URL from the browser
- Strips the `vlc://` protocol prefix
- Repairs malformed URL formatting (double slashes from URL encoding)
- Launches VLC with the cleaned URL

#### 3. **browser-policies.reg** - Registry File (Alternative Installation)
- Alternative installation method for registry entries
- Can be imported directly using Registry Editor
- Includes policies for Chrome and Edge
- Note: Still requires manual wrapper deployment

#### 4. **uninstall.ps1** - Cleanup Script
- Removes the `vlc://` protocol registry entries
- Deletes browser auto-launch policies
- Removes the wrapper script from VLC directory
- Restores system to pre-installation state

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

The wrapper dynamically locates VLC during installation. If your VLC is installed in a custom location:

1. **Manual installation:** Edit `vlc-wrapper.ps1` directly:
   ```powershell
   $vlcPath = "C:\Your\Custom\Path\vlc.exe"
   ```

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
2. Edit `install.ps1` line 14 and add your custom path to `$vlcPaths`
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

## 📝 Registry Details

### HKEY_CLASSES_ROOT\VLC

```
VLC (Default)               = "URL:VLC Protocol"
VLC\URL Protocol (Default)  = "" (empty string)
VLC\shell\open\command      = MSHTA invocation to vlc-wrapper.ps1
```

### Browser Policies

```json
{
  "allowed_origins": [
    "https://stremio.com",
    "https://web.stremio.com",
    "https://strem.io",
    "https://app.strem.io"
  ],
  "protocol": "vlc"
}
```

## ⚠️ Security Considerations

- **Administrator required:** Installation modifies system registry and requires elevation
- **White-listed origins:** Only specified Stremio domains can trigger VLC launch
- **URL validation:** The wrapper cleans URLs to prevent injection attacks
- **No persistence:** VLC process is independent; wrapper doesn't maintain connections

## 📄 License

This project is provided as-is for personal use.

## 🤝 Contributing

To report issues or suggest improvements, please open an issue in the repository.

## 🔗 Related Resources

- [Stremio Official Website](https://www.stremio.com/)
- [VLC Media Player](https://www.videolan.org/vlc/)
- [Windows Protocol Handlers](https://learn.microsoft.com/en-us/windows/win32/lwef/-search-2x-wds-ph-install-registration)
- [Chrome Auto-Launch Protocol Policy](https://chromedriver.chromium.org/security-considerations)
- [Edge Policy Reference](https://docs.microsoft.com/en-us/deployedge/microsoft-edge-policies)

---

**Last Updated:** November 2026
