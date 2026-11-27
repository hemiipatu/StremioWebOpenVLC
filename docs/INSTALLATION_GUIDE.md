# Installation Guide - StremioWebOpenVLC

A step-by-step guide to install, verify, and troubleshoot the Stremio VLC protocol handler.

## Table of Contents

1. [Before You Start](#before-you-start)
2. [Automated Installation](#automated-installation)
3. [Manual Installation (Registry File)](#manual-installation-registry-file)
4. [Verification Steps](#verification-steps)
5. [Advanced Configuration](#advanced-configuration)
6. [Troubleshooting](#troubleshooting)
7. [Uninstallation](#uninstallation)

---

## Before You Start

### Prerequisites Checklist

- [ ] **Windows 10 or 11** (Home, Pro, or Enterprise editions)
- [ ] **VLC Media Player installed** from [videolan.org](https://www.videolan.org/vlc/)
- [ ] **Administrator access** on your Windows user account
- [ ] **Chrome or Edge browser** (both can be used together)
- [ ] **Stremio account** at [stremio.com](https://www.stremio.com/)
- [ ] **PowerShell** available (built-in to Windows)

### What Gets Installed

This installation will:
- ✅ Add `vlc://` as a recognized Windows protocol
- ✅ Deploy a wrapper script to your VLC installation folder
- ✅ Configure browser policies for Chrome and/or Edge
- ✅ **NOT** modify VLC itself or browser data
- ✅ **NOT** require internet access

---

## Automated Installation

### Method 1: PowerShell Installation (Recommended)

This is the easiest and most reliable method.

#### Step 1: Download the Repository

**Option A - Via Git (if installed):**
```powershell
git clone https://github.com/hemiipatu/StremioWebOpenVLC.git
cd StremioWebOpenVLC
```

**Option B - Manual Download:**
1. Visit: https://github.com/hemiipatu/StremioWebOpenVLC
2. Click **Code** → **Download ZIP**
3. Extract to a folder (e.g., `C:\Users\YourName\Downloads\StremioWebOpenVLC`)
4. Open PowerShell in that folder

#### Step 2: Launch PowerShell as Administrator

**Method A - Quick Launch:**
1. Press `Windows Key + X`
2. Select **Windows PowerShell (Admin)** or **Terminal (Admin)**
3. Click **Yes** at the UAC prompt

**Method B - Via Windows Search:**
1. Press `Windows Key`
2. Type `powershell`
3. Right-click **Windows PowerShell**
4. Select **Run as Administrator**
5. Click **Yes** at the UAC prompt

**Method C - From File Explorer:**
1. Open File Explorer
2. Navigate to your repository folder
3. Hold `Shift` and right-click in empty space
4. Select **Open PowerShell window here** (or Terminal)
5. Run: `Start-Process powershell -ArgumentList '-NoExit', '-Command', 'Set-Location $pwd' -Verb RunAs`

#### Step 3: Verify Administrator Status

In PowerShell, verify you're running as Administrator:
```powershell
whoami
```

You should see output like: `DOMAIN\USERNAME`

If you see an error or the prompt says "PowerShell", restart using the methods above.

#### Step 4: Run the Installation Script

```powershell
.\install.ps1
```

**Expected Output:**
```
[+] Locating VLC Media Player...
    Found VLC at: C:\Program Files\VideoLAN\VLC\vlc.exe
[+] Deploying vlc-wrapper.ps1 to C:\Program Files\VideoLAN\VLC...
    vlc-wrapper.ps1 created successfully.
[+] Registering 'vlc://' custom URL protocol...
    vlc:// protocol registered successfully.
[+] Configuring browser auto-launch policies...
    Updated policy at: HKLM:\SOFTWARE\Policies\Google\Chrome
    Updated policy at: HKLM:\SOFTWARE\Policies\Microsoft\Edge
[SUCCESS] Installation complete! Please reload policies via chrome://policy and edge://policy.
```

**If you see errors:**
- See [Troubleshooting](#troubleshooting) section below

#### Step 5: Reload Browser Policies

This ensures the browser recognizes the new protocol handler immediately.

**For Google Chrome:**
1. Open Chrome
2. Navigate to: `chrome://policy`
3. Click the **"Reload policies"** button
4. Verify `AutoLaunchProtocolsFromOrigins` is listed

**For Microsoft Edge:**
1. Open Edge
2. Navigate to: `edge://policy`
3. Click the **"Reload policies"** button
4. Verify `AutoLaunchProtocolsFromOrigins` is listed

#### Step 6: Test the Installation

1. Open your browser (Chrome or Edge)
2. Go to: https://web.stremio.com or https://stremio.com
3. Log in with your Stremio account
4. Click on any streaming link
5. **Expected:** VLC opens automatically with the stream

✅ **Installation successful!**

---

## Manual Installation (Registry File)

Use this method if you prefer not to run PowerShell scripts.

### Step 1: Edit the Registry File

1. Open `browser-policies.reg` with Notepad
2. Check the VLC path on this line:
   ```
   @="mshta.exe vbscript:Execute(\"CreateObject...C:\\Program Files\\VideoLAN\\VLC\\vlc-wrapper.ps1
   ```
3. If your VLC is in a different location, update the path

### Step 2: Import the Registry File

**Method A - Direct Double-Click:**
1. Right-click `browser-policies.reg`
2. Select **Edit with... → Notepad** (verify the paths first!)
3. Close Notepad
4. Double-click `browser-policies.reg`
5. Click **Yes** at the registry prompt

**Method B - Via Registry Editor:**
1. Press `Windows Key + R`
2. Type `regedit` and press Enter
3. Click **Yes** at the UAC prompt
4. Go to **File → Import**
5. Select `browser-policies.reg`
6. Click **Import** → **OK**

**Method C - Via Command Prompt (Admin):**
1. Open Command Prompt as Administrator
2. Navigate to the repository folder:
   ```cmd
   cd C:\path\to\StremioWebOpenVLC
   ```
3. Run:
   ```cmd
   reg import browser-policies.reg
   ```

### Step 3: Deploy the Wrapper Script

This must be done manually:

1. Locate your VLC installation:
   - Standard: `C:\Program Files\VideoLAN\VLC\`
   - 32-bit: `C:\Program Files (x86)\VideoLAN\VLC\`

2. Copy `vlc-wrapper.ps1` to that VLC folder

3. Verify the wrapper path matches what you set in `browser-policies.reg`

### Step 4: Reload Browser Policies

Follow the same steps as Method 1, Step 5 above.

---

## Verification Steps

After installation, verify everything is working correctly.

### Check 1: Registry Entries

1. Press `Windows Key + R`
2. Type `regedit` and press Enter
3. Navigate to: `HKEY_CLASSES_ROOT\VLC`
4. You should see:
   - **VLC** (folder)
     - (Default) = `URL:VLC Protocol`
     - URL Protocol = `(empty string)`
   - **VLC\shell\open\command**
     - (Default) = `mshta.exe vbscript:Execute...`

### Check 2: Wrapper Script Location

1. Open File Explorer
2. Navigate to: `C:\Program Files\VideoLAN\VLC\` (or your VLC directory)
3. You should see: `vlc-wrapper.ps1`
4. Right-click it → **Open with → PowerShell ISE** to view its contents

### Check 3: Browser Policies

**Chrome:**
1. Open Chrome
2. Go to: `chrome://policy`
3. Verify `AutoLaunchProtocolsFromOrigins` is listed
4. Check the value includes your Stremio domain

**Edge:**
1. Open Edge
2. Go to: `edge://policy`
3. Verify `AutoLaunchProtocolsFromOrigins` is listed
4. Check the value includes your Stremio domain

### Check 4: Protocol Handler Test

1. Open any application that can handle URLs (Notepad, Word, etc.)
2. Type: `vlc://https://example.com/stream.m3u8`
3. Click on it or paste it in your browser address bar
4. **Expected:** VLC opens (with or without the stream, depending on the URL)

### Check 5: Live Test with Stremio

1. Open Stremio in Chrome or Edge
2. Go to any content with a playback option
3. Click **Play** or the streaming link
4. **Expected:** VLC opens automatically without prompting

---

## Advanced Configuration

### Adding Custom Domains

To allow additional domains to auto-launch VLC:

#### Via PowerShell (Manual Edit):

1. Open Registry Editor (`regedit`)
2. Navigate to:
   - `HKLM:\SOFTWARE\Policies\Google\Chrome`
   - `HKLM:\SOFTWARE\Policies\Microsoft\Edge`
3. Right-click `AutoLaunchProtocolsFromOrigins` → **Edit**
4. Find the JSON value and add your domain:
   ```json
   [{"allowed_origins":["https://stremio.com","https://web.stremio.com","https://strem.io","https://app.strem.io","https://yourcustom.domain"],"protocol":"vlc"}]
   ```
5. Click **OK**
6. Reload browser policies

### Modifying the Wrapper Script

Advanced users can customize URL processing in `vlc-wrapper.ps1`:

```powershell
param([string]$rawUrl)

if ($rawUrl) {
    # Custom URL processing here
    $cleanUrl = $rawUrl -replace '^vlc://', ''
    $cleanUrl = $cleanUrl -replace '^https//', 'https://'
    
    # Your custom logic:
    $cleanUrl = $cleanUrl -replace 'oldvalue', 'newvalue'
    
    $vlcPath = "C:\Program Files\VideoLAN\VLC\vlc.exe"
    if (Test-Path $vlcPath) {
        Start-Process -FilePath $vlcPath -ArgumentList "`"$cleanUrl`""
    }
}
```

After editing, re-run `install.ps1` to redeploy the changes.

---

## Troubleshooting

### Issue 1: "This script must be run as Administrator"

**Cause:** PowerShell doesn't have admin privileges

**Solutions:**
1. Close PowerShell
2. Press `Windows Key + X`
3. Select **Windows PowerShell (Admin)** or **Terminal (Admin)**
4. Click **Yes** at the UAC prompt
5. Run `.\install.ps1` again

**Still getting error?**
- Check: Settings → Update & Security → For developers → **Enable Developer Mode**
- Or use Command Prompt (Admin) instead:
  ```cmd
  powershell -ExecutionPolicy Bypass -File install.ps1
  ```

---

### Issue 2: "Could not locate vlc.exe in standard Program Files directories"

**Cause:** VLC is installed in a non-standard location

**Solutions:**

**Option A - Find VLC Manually:**
```powershell
# In PowerShell (Admin), run:
Get-ChildItem -Path "C:\" -Recurse -Filter "vlc.exe" -ErrorAction SilentlyContinue
```

**Option B - Edit the Script:**
1. Open `install.ps1` with Notepad
2. Find this section (around line 14):
   ```powershell
   $vlcPaths = @(
       "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe",
       "${env:ProgramFiles(x86)}\VideoLAN\VLC\vlc.exe"
   )
   ```
3. Add your custom path:
   ```powershell
   $vlcPaths = @(
       "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe",
       "${env:ProgramFiles(x86)}\VideoLAN\VLC\vlc.exe",
       "C:\Your\Custom\Path\vlc.exe"
   )
   ```
4. Save and run `install.ps1` again

**Option C - Manual Installation:**
1. Copy the wrapper manually to your VLC directory
2. Import `browser-policies.reg`
3. Edit the registry to point to your VLC location

---

### Issue 3: Clicking Stremio links doesn't open VLC

**Cause:** Browser policies not applied or cached

**Solutions:**

1. **Restart the browser completely:**
   - Close ALL browser windows and tabs
   - Wait 10 seconds
   - Reopen the browser
   - Try again

2. **Reload policies:**
   - Chrome: Go to `chrome://policy` → **Reload policies**
   - Edge: Go to `edge://policy` → **Reload policies**

3. **Update Group Policy (if on Windows Pro/Enterprise):**
   ```cmd
   gpupdate /force
   ```

4. **Check the policy is set:**
   ```powershell
   # PowerShell (Admin)
   Get-ItemProperty -Path "HKLM:\SOFTWARE\Policies\Google\Chrome" -Name "AutoLaunchProtocolsFromOrigins"
   ```
   If empty or not found, re-run `install.ps1`

5. **Verify browser supports the policy:**
   - Minimum Chrome version: 53
   - Minimum Edge version: 79
   - Run: `chrome://version` or `edge://version` to check your version

---

### Issue 4: VLC opens but without the stream URL

**Cause:** URL formatting issue or VLC path hardcoded incorrectly

**Solutions:**

1. **Check the wrapper script:**
   ```powershell
   # Edit the wrapper:
   Notepad "C:\Program Files\VideoLAN\VLC\vlc-wrapper.ps1"
   ```
   Verify the `$vlcPath` points to your actual VLC executable

2. **Re-run installation:**
   ```powershell
   .\uninstall.ps1
   .\install.ps1
   ```

3. **Enable debug logging:**
   Modify `vlc-wrapper.ps1` to add logging:
   ```powershell
   param([string]$rawUrl)
   
   "Raw URL: $rawUrl" | Out-File -Path "C:\temp\vlc-debug.log" -Append
   
   if ($rawUrl) {
       $cleanUrl = $rawUrl -replace '^vlc://', ''
       "Clean URL: $cleanUrl" | Out-File -Path "C:\temp\vlc-debug.log" -Append
       ...
   }
   ```

---

### Issue 5: "AutoLaunchProtocolsFromOrigins" not applying

**Cause:** Group Policy object (GPO) not reloaded or policy conflicts

**Solutions:**

1. **Force Group Policy update:**
   ```cmd
   gpupdate /force
   ```

2. **Check for conflicting policies:**
   - If using Windows Pro/Enterprise, a domain admin might have overriding policies
   - Check with your IT department

3. **Restart computer:**
   Sometimes a full restart is needed for registry changes to take effect

4. **Check browser version:**
   - Policy support requires Chrome 53+ or Edge 79+
   - Update your browser if outdated

5. **Verify policy manually:**
   ```powershell
   # PowerShell (Admin)
   reg query "HKLM\SOFTWARE\Policies\Google\Chrome" /v AutoLaunchProtocolsFromOrigins
   reg query "HKLM\SOFTWARE\Policies\Microsoft\Edge" /v AutoLaunchProtocolsFromOrigins
   ```

---

### Issue 6: Permission Denied when writing to VLC folder

**Cause:** VLC installed with restricted permissions

**Solutions:**

1. **Run PowerShell as Administrator** (see Issue 1)

2. **Take ownership of VLC folder:**
   ```cmd
   # Command Prompt (Admin)
   takeown /f "C:\Program Files\VideoLAN\VLC" /r
   icacls "C:\Program Files\VideoLAN\VLC" /grant "%USERNAME%":F /t
   ```

3. **Move VLC to a different location:**
   - Uninstall VLC
   - Reinstall to a user-writable location
   - Re-run `install.ps1`

---

### Issue 7: Registry file import fails

**Cause:** File format corruption or path issues

**Solutions:**

1. **Verify the file:**
   ```powershell
   file "browser-policies.reg"
   Get-Content "browser-policies.reg" | head -5
   ```

2. **Edit paths in the registry file:**
   - Open `browser-policies.reg` with Notepad
   - Check all file paths are correct (especially backslashes)
   - Save as **ANSI** encoding, not UTF-8

3. **Use PowerShell instead:**
   ```powershell
   .\install.ps1
   ```

---

## Uninstallation

To completely remove the VLC protocol handler and restore your system:

### Automated Uninstallation (Recommended)

1. Open PowerShell as Administrator
2. Navigate to the repository:
   ```powershell
   cd C:\path\to\StremioWebOpenVLC
   ```
3. Run:
   ```powershell
   .\uninstall.ps1
   ```

**Expected Output:**
```
[+] Removing 'vlc://' protocol registry key...
    Removed registry key: Registry::HKEY_CLASSES_ROOT\VLC
[+] Cleaning up AutoLaunchProtocolsFromOrigins browser policies...
    Removed AutoLaunchProtocolsFromOrigins from: HKLM:\SOFTWARE\Policies\Google\Chrome
    Removed AutoLaunchProtocolsFromOrigins from: HKLM:\SOFTWARE\Policies\Microsoft\Edge
[+] Deleting vlc-wrapper.ps1 script...
    Deleted file: C:\Program Files\VideoLAN\VLC\vlc-wrapper.ps1
[SUCCESS] Cleanup complete! Custom VLC protocol and policy configurations have been removed.
```

### Manual Uninstallation

If you prefer to clean up manually:

1. **Delete the wrapper script:**
   - Navigate to: `C:\Program Files\VideoLAN\VLC\`
   - Delete: `vlc-wrapper.ps1`

2. **Remove registry keys:**
   - Open Registry Editor (`regedit`)
   - Navigate to: `HKEY_CLASSES_ROOT\VLC`
   - Right-click **VLC** → **Delete**
   - Click **Yes**

3. **Remove browser policies:**
   - Navigate to: `HKLM:\SOFTWARE\Policies\Google\Chrome`
   - Right-click `AutoLaunchProtocolsFromOrigins` → **Delete**
   - Navigate to: `HKLM:\SOFTWARE\Policies\Microsoft\Edge`
   - Right-click `AutoLaunchProtocolsFromOrigins` → **Delete**

4. **Reload browser policies:**
   - Chrome: `chrome://policy` → **Reload policies**
   - Edge: `edge://policy` → **Reload policies**

---

## Support

If you encounter issues not covered here:

1. **Check the main README.md** for additional documentation
2. **Search GitHub issues:** https://github.com/hemiipatu/StremioWebOpenVLC/issues
3. **Create a new issue** with:
   - Your Windows version (`winver`)
   - VLC installation path
   - Browser and version
   - Full error message output
   - Steps to reproduce the issue

---

**Last Updated:** November 2026
