<#
.SYNOPSIS
    Sets the branded wallpaper as desktop background if not detected on the device
#>

$registryPath = "HKCU:\Control Panel\Desktop"
$destinationFolder = "C:\Users\Public\Documents\Branded Wallpapers"
$wallpaperPath = "$destinationFolder\new_wallpaper.jpg"
$imageUrl = "https://images.pexels.com/photos/3848158/pexels-photo-3848158.jpeg" # Direct link

# 1. Check if the file exists
if (Test-Path -Path $wallpaperPath) {
    Write-Output "Wallpaper was found. No action needed."
}
else {
    Write-Output "Wallpaper missing. Starting remediation..."
    
    # 2. Create folder safely
    New-Item -ItemType Directory -Path $destinationFolder -Force | Out-Null

    # 3. Download the file directly to the destination
    try {
        Invoke-WebRequest -Uri $imageUrl -OutFile $wallpaperPath -ErrorAction Stop
        Write-Output "Download successful."
    } 
    catch {
        Write-Error "Failed to download image: $($_.Exception.Message)"
        Exit 1 # Exit with failure so Intune knows it didn't work
    }

    # 4. Update the Registry
    Set-ItemProperty -Path $registryPath -Name "WallPaper" -Value $wallpaperPath

    # 5. Refresh the desktop (The "Poke")
    # Note: Running this once is usually enough; the loop is a bit heavy but ensures it hits.
    & RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True
    
    Write-Output "Wallpaper was changed and system notified."
}
