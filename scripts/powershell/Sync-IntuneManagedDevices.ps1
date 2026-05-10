<#
.SYNOPSIS
    Syncs all Windows Intune managed devices directly from Microsoft Graph.
    
.NOTES
    The below modules need to be installed in order to run this script:

    Install-Module -Name Microsoft.Graph

#>

Connect-MgGraph -Scopes "DeviceManagementManagedDevices.PrivilegedOperations.All"

# 1. Define Filter (Only get Windows devices that are currently 'managed')
$filter = "operatingSystem eq 'Windows'"

Write-Host "Fetching Windows devices from Intune..." -ForegroundColor Cyan
$devices = Get-MgDeviceManagementManagedDevice -Filter $filter -Property "Id", "DeviceName"

if ($null -eq $devices) {
    Write-Host "No devices found matching the criteria." -ForegroundColor Red
    return
}

Write-Host "Found $($devices.Count) devices. Starting bulk sync..." -ForegroundColor Cyan

foreach ($device in $devices) {
    $params = @{
        ManagedDeviceId = $device.Id
    }

    try {
        # Perform the sync
        Sync-MgDeviceManagementManagedDevice @params -ErrorAction Stop
        Write-Host "SUCCESS: Sync initiated for $($device.DeviceName) ($($device.Id))" -ForegroundColor Green
    } 
    catch {
        Write-Host "FAILURE: Could not sync $($device.DeviceName). Error: $($_.Exception.Message)" -ForegroundColor Yellow
    }
}
