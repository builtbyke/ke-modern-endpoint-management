<#
.SYNOPSIS
    Sets the branded wallpaper as desktop background if not detected on the device/registry
#>

$registryPath = "HKCU:\Control Panel\Desktop"
$destinationFolder = "C:\Users\Public\Documents\Branded Wallpapers"
$wallpaperPath = "$destinationFolder\oshh-desktop-wallpaper-1920x1080.png"
$imageUrl = "https://oshh-branded-images.s3.us-east-1.amazonaws.com/oshh-desktop-wallpaper-1920x1080.png" # Direct link
$value = (Get-ItemProperty -Path $registryPath -Name WallPaper -ErrorAction SilentlyContinue).WallPaper

# 1. Check if the correct registry value exists
if ($value -eq $wallpaperPath) {
    Write-Output "Wallpaper is correct"
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

    # 5. Refreshes the desktop
    & RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True
    
    Write-Output "Wallpaper was changed and system notified."
}
