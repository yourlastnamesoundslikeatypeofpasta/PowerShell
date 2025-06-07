function Get-CommonSystemInfo {
    <#
    .SYNOPSIS
        Returns common system information such as OS and hardware details.
    .DESCRIPTION
        Collects operating system, processor, disk and memory information using
        CIM classes and returns it as a custom object.
    #>
    [CmdletBinding()]
    param()

    process {
        Import-Module (Join-Path $PSScriptRoot '../../Logging/Logging.psd1') -ErrorAction SilentlyContinue

        Write-STStatus 'Collecting system information...' -Level INFO

        if (Get-Command -Name Get-CimInstance -ErrorAction SilentlyContinue) {
            $operatingSystemInfo = Get-CimInstance -ClassName Win32_OperatingSystem
            $processorInfo       = Get-CimInstance -ClassName Win32_Processor
            $diskInfo            = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3"
            $memoryInfo          = Get-CimInstance -ClassName Win32_PhysicalMemory
        } elseif (Get-Command -Name Get-WmiObject -ErrorAction SilentlyContinue) {
            $operatingSystemInfo = Get-WmiObject -Class Win32_OperatingSystem
            $processorInfo       = Get-WmiObject -Class Win32_Processor
            $diskInfo            = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType = 3"
            $memoryInfo          = Get-WmiObject -Class Win32_PhysicalMemory
        } else {
            throw "CIM or WMI cmdlets are not available"
        }

        $commonSystemInfoObj = [pscustomobject]@{
            ComputerName = $operatingSystemInfo.CSName
            OSVersion    = $operatingSystemInfo.Caption
            OSBuild      = $operatingSystemInfo.BuildNumber
            Processor    = $processorInfo.Name
            Memory       = $operatingSystemInfo.TotalVisibleMemorySize / 1MB
            DiskSpace    = $diskInfo | Select-Object -Property DeviceID,
                            @{Name = 'Size'; Expression = { "{0:N2}" -f ($_.Size / 1GB) }},
                            @{Name = 'FreeSpace'; Expression = { "{0:N2}" -f ($_.FreeSpace / 1GB) }}
        }
        Write-STStatus 'System information collected.' -Level SUCCESS

        return $commonSystemInfoObj
    }
}
