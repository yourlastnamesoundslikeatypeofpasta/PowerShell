function Get-CommonSystemInfo {
    <#
    .SYNOPSIS
        Returns common system information such as OS and hardware details.
    .DESCRIPTION
        Collects operating system, processor, disk and memory information using
        CIM classes and returns it as a custom object. The MemoryGB value is
        reported in gigabytes (GB).
    .OUTPUTS
        PSCustomObject with ComputerName, OSVersion, OSBuild, Processor,
        MemoryGB (GB) and DiskSpace details.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNull()]
        [object]$Logger,
        [Parameter(Mandatory = $false)]
        [ValidateNotNull()]
        [object]$TelemetryClient,
        [Parameter(Mandatory = $false)]
        [ValidateNotNull()]
        [object]$Config
    )

    process {
        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        $result = 'Success'
        try {
            if ($Logger) {
                Import-Module $Logger -Force -ErrorAction SilentlyContinue
            } else {
                Import-Module (Join-Path $PSScriptRoot '../../Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
            }
            if ($TelemetryClient) {
                Import-Module $TelemetryClient -Force -ErrorAction SilentlyContinue
            } else {
                Import-Module (Join-Path $PSScriptRoot '../../Telemetry/Telemetry.psd1') -Force -ErrorAction SilentlyContinue
            }
            if ($Config) {
                Import-Module $Config -Force -ErrorAction SilentlyContinue
            }

            Write-STStatus -Message 'Collecting system information...' -Level INFO

            if (Get-Command -Name Get-CimInstance -ErrorAction SilentlyContinue) {
                $operatingSystemInfo = Get-CimInstance -ClassName Win32_OperatingSystem
                $processorInfo       = Get-CimInstance -ClassName Win32_Processor
                $diskInfo            = Get-CimInstance -ClassName Win32_LogicalDisk -Filter "DriveType = 3"
                $memoryInfo          = Get-CimInstance -ClassName Win32_PhysicalMemory
                $memoryGB            = $operatingSystemInfo.TotalVisibleMemorySize / 1MB
                if ($memoryGB % 1 -eq 0) { $memoryGB = [int]$memoryGB } else { $memoryGB = [double]$memoryGB }
            } elseif (Get-Command -Name Get-WmiObject -ErrorAction SilentlyContinue) {
                $operatingSystemInfo = Get-WmiObject -Class Win32_OperatingSystem
                $processorInfo       = Get-WmiObject -Class Win32_Processor
                $diskInfo            = Get-WmiObject -Class Win32_LogicalDisk -Filter "DriveType = 3"
                $memoryInfo          = Get-WmiObject -Class Win32_PhysicalMemory
                $memoryGB            = $operatingSystemInfo.TotalVisibleMemorySize / 1MB
                if ($memoryGB % 1 -eq 0) { $memoryGB = [int]$memoryGB } else { $memoryGB = [double]$memoryGB }
            } else {
                throw "CIM or WMI cmdlets are not available"
            }

            $commonSystemInfoObj = [pscustomobject]@{
                ComputerName = $operatingSystemInfo.CSName
                OSVersion    = $operatingSystemInfo.Caption
                OSBuild      = $operatingSystemInfo.BuildNumber
                Processor    = $processorInfo.Name
                MemoryGB     = $memoryGB
                DiskSpace    = $diskInfo | Select-Object -Property DeviceID,
                                @{Name = 'Size'; Expression = { "{0:N2}" -f ($_.Size / 1GB) }},
                                @{Name = 'FreeSpace'; Expression = { "{0:N2}" -f ($_.FreeSpace / 1GB) }}
            }
            Write-STStatus -Message 'System information collected.' -Level SUCCESS
            return $commonSystemInfoObj
        } catch {
            Write-STStatus "Get-CommonSystemInfo failed: $_" -Level ERROR -Log
            Write-STLog -Message "Get-CommonSystemInfo failed: $_" -Level ERROR
            $result = 'Failure'
            return New-STErrorObject -Message $_.Exception.Message -Category 'WMI'
        } finally {
            $sw.Stop()
            Send-STMetric -MetricName 'Get-CommonSystemInfo' -Category 'Audit' -Value $sw.Elapsed.TotalSeconds -Details @{ Result = $result }
        }
    }
}
