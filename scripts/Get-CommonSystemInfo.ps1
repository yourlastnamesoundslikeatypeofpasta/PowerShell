Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue

function Get-CommonSystemInfo {
    [CmdletBinding()]
    param()
    <#
    .SYNOPSIS
    Gather OS version, processor details, memory and disk space.
    
    .DESCRIPTION
    Using Get-CimInstance -Class Win32_OperatingSystem, Win32_Processor, Win32_LogicalDisk and Win32_PhysicalMemory to gather OS version, processor details, memory and disk space. The MemoryGB value is reported in gigabytes (GB).
    
    .EXAMPLE
    Get-CommonSystemInfo    
    
    .NOTES
    Running this function will return a custom object with the following properties:
    - ComputerName
    - OSVersion
    - OSBuild
    - Processor
    - MemoryGB (GB)
    - DiskSpace (per drive in GB)
    #>

    Write-STStatus -Message 'Collecting system information...' -Level INFO

    $operatingSystemInfo = Get-CimInstance -ClassName Win32_OperatingSystem
    $processorInfo = Get-CimInstance -ClassName Win32_Processor
    $diskInfo = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3"
    $memoryInfo = Get-CimInstance -ClassName Win32_PhysicalMemory

    $memoryGB = $operatingSystemInfo.TotalVisibleMemorySize / 1MB
    if ($memoryGB % 1 -eq 0) { $memoryGB = [int]$memoryGB } else { $memoryGB = [double]$memoryGB }

    $commonSystemInfoObj = [pscustomobject]@{
        ComputerName = $operatingSystemInfo.CSName
        OSVersion = $operatingSystemInfo.Caption
        OSBuild = $operatingSystemInfo.BuildNumber
        Processor = $processorInfo.Name
        MemoryGB = $memoryGB
        DiskSpace = $diskInfo | Select-Object -Property DeviceID, @{Name = "Size"; Expression = { "{0:N2}" -f ($_.Size / 1GB) }}, @{Name = "FreeSpace"; Expression = { "{0:N2}" -f ($_.FreeSpace / 1GB) }}
    }
    Write-STStatus -Message 'System information collected.' -Level SUCCESS
    return $commonSystemInfoObj
}