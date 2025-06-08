$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue

function Get-DiskSpace {
    <#
    .SYNOPSIS
        Returns disk size and free space information.
    #>
    [CmdletBinding()]
    param(
        [string]$DriveLetter
    )
    if ($PSVersionTable.PSEdition -eq 'Desktop' -or $IsWindows) {
        $filter = 'DriveType = 3'
        if ($DriveLetter) { $filter += " AND DeviceID='$DriveLetter'" }
        Get-CimInstance -ClassName Win32_LogicalDisk -Filter $filter |
            Select-Object DeviceID,
                @{Name='SizeGB';Expression={"{0:N2}" -f ($_.Size / 1GB)}},
                @{Name='FreeGB';Expression={"{0:N2}" -f ($_.FreeSpace / 1GB)}}
    } else {
        $drives = Get-PSDrive -PSProvider FileSystem
        if ($DriveLetter) { $drives = $drives | Where-Object { $_.Name -eq $DriveLetter } }
        $drives | Select-Object Name,
            @{Name='SizeGB';Expression={"{0:N2}" -f ($_.Used/1GB + $_.Free/1GB)}},
            @{Name='FreeGB';Expression={"{0:N2}" -f ($_.Free/1GB)}}
    }
}

function Get-CPUUsage {
    <#
    .SYNOPSIS
        Returns average CPU usage percentage.
    #>
    [CmdletBinding()]
    param(
        [int]$Samples = 3
    )
    if (Get-Command Get-Counter -ErrorAction SilentlyContinue) {
        $data = Get-Counter '\\Processor(_Total)\\% Processor Time' -SampleInterval 1 -MaxSamples $Samples
        return [math]::Round(($data.CounterSamples | Measure-Object -Property CookedValue -Average).Average,2)
    } elseif (Get-Command Get-CimInstance -ErrorAction SilentlyContinue) {
        $cpu = Get-CimInstance -ClassName Win32_Processor | Select-Object -First 1 -ExpandProperty LoadPercentage
        return [int]$cpu
    } else {
        Write-STStatus 'Unable to determine CPU usage on this platform.' -Level WARN
        return $null
    }
}

function Get-EventLogSummary {
    <#
    .SYNOPSIS
        Retrieves recent Application and System event logs.
    #>
    [CmdletBinding()]
    param(
        [int]$MaxEvents = 50
    )
    if ($IsWindows -and (Get-Command Get-EventLog -ErrorAction SilentlyContinue)) {
        $app = Get-EventLog -LogName Application -Newest $MaxEvents
        $sys = Get-EventLog -LogName System -Newest $MaxEvents
        return [pscustomobject]@{ Application = $app; System = $sys }
    } else {
        Write-STStatus 'Event logs not available on this platform.' -Level WARN
        return $null
    }
}

function Get-SystemHealth {
    <#
    .SYNOPSIS
        Provides an overview of system health metrics.
    #>
    [CmdletBinding()]
    param(
        [int]$EventCount = 20
    )
    $cpu  = Get-CPUUsage
    $disk = Get-DiskSpace
    $logs = Get-EventLogSummary -MaxEvents $EventCount
    [pscustomobject]@{
        CPUPercent = $cpu
        Disk       = $disk
        Events     = $logs
    }
}

Export-ModuleMember -Function 'Get-DiskSpace','Get-CPUUsage','Get-EventLogSummary','Get-SystemHealth'

function Show-MonitoringToolsBanner {
    <#
    .SYNOPSIS
        Displays the MonitoringTools module banner.
    #>
    [CmdletBinding()]
    param()
    Write-STDivider 'MONITORINGTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module MonitoringTools' to view available tools." -Level SUB
    Write-STLog -Message 'MonitoringTools module loaded'
}

Show-MonitoringToolsBanner
