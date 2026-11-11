param([string]$rawUrl)

if ($rawUrl) {
    # Clean the vlc:// protocol wrapper and fix URL formatting
    $cleanUrl = $rawUrl -replace '^vlc://', ''
    $cleanUrl = $cleanUrl -replace '^https//', 'https://'
    $cleanUrl = $cleanUrl -replace '^http//', 'http://'

    $vlcPath = "C:\Program Files\VideoLAN\VLC\vlc.exe"
    
    if (Test-Path $vlcPath) {
        Start-Process -FilePath $vlcPath -ArgumentList "`"$cleanUrl`""
    }
}