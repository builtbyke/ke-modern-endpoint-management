<# 
.SYNOPSIS
    Detects if branded wallpaper is on the device and currently set as background
#>

$registryPath = "HKCU:\Control Panel\Desktop\"
$value = (Get-ItemProperty -Path $registryPath -Name WallPaper -ErrorAction SilentlyContinue).WallPaper
$wallpaperPath = "C:\Users\Public\Documents\Branded Wallpapers\new_wallpaper.jpg"

if ($value -eq $wallpaperPath) {
    Write-Output "Wallpaper is a match"
    Exit 0
} else {
    Write-Output "Does not match! Needs fixing."
    Exit 1
}
