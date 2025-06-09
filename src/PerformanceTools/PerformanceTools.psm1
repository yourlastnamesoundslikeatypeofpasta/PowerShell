$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
Import-Module $coreModule -Force -ErrorAction SilentlyContinue
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $loggingModule -Force -ErrorAction SilentlyContinue

function Measure-STCommand {
    <#
    .SYNOPSIS
        Measures execution time, CPU usage and memory change for a script block.
    .DESCRIPTION
        Executes the provided script block and returns the elapsed time in seconds,
        processor time consumed and the change in working set memory in megabytes.
    .PARAMETER ScriptBlock
        The commands to execute.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [scriptblock]$ScriptBlock,
        [switch]$Quiet
    )

    Assert-ParameterNotNull $ScriptBlock 'ScriptBlock'

    $before = Get-Process -Id $PID
    $cpuStart = $before.TotalProcessorTime
    $memStart = $before.WorkingSet64
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $errorObj = $null
    try {
        & $ScriptBlock
    } catch {
        Write-STStatus "Measure-STCommand failed: $_" -Level ERROR -Log
        Write-STLog -Message "Measure-STCommand failed: $_" -Level ERROR -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
        $errorObj = New-STErrorObject -Message $_.Exception.Message -Category 'Performance'
    } finally {
        $sw.Stop()
    }

    $after = Get-Process -Id $PID
    $cpuEnd = $after.TotalProcessorTime
    $memEnd = $after.WorkingSet64

    $result = [pscustomobject]@{
        DurationSeconds = [math]::Round($sw.Elapsed.TotalSeconds, 2)
        CpuSeconds      = [math]::Round(($cpuEnd - $cpuStart).TotalSeconds, 2)
        MemoryDeltaMB   = [math]::Round(($memEnd - $memStart) / 1MB, 2)
    }

    if (-not $Quiet) {
        Write-STStatus "Duration: $($result.DurationSeconds)s" -Level INFO
        Write-STStatus "CPU Time: $($result.CpuSeconds)s" -Level INFO
        Write-STStatus "Memory Change: $($result.MemoryDeltaMB) MB" -Level INFO
    }

    if ($errorObj) {
        Send-STMetric -MetricName 'Measure-STCommand' -Category 'Performance' -Value $sw.Elapsed.TotalSeconds -Details @{ Result = 'Failure'; CpuSeconds = ($cpuEnd - $cpuStart).TotalSeconds; MemoryDeltaMB = [math]::Round(($memEnd - $memStart) / 1MB, 2) }
        return $errorObj
    }
    Send-STMetric -MetricName 'Measure-STCommand' -Category 'Performance' -Value $result.DurationSeconds -Details @{ CpuSeconds = $result.CpuSeconds; MemoryDeltaMB = $result.MemoryDeltaMB }
    return $result
}

function Invoke-PerformanceAudit {
    <#
    .SYNOPSIS
        Collects CPU, memory, disk and network metrics.
    .DESCRIPTION
        This wrapper runs Invoke-PerformanceAudit.ps1 located in the module
        folder and forwards any provided parameters to that script.
    #>
    [CmdletBinding()]
    param(
        [int]$CpuThreshold = 80,
        [int]$MemoryThreshold = 80,
        [int]$DiskThreshold = 80,
        [int]$NetworkThreshold = 100,
        [switch]$CreateTicket,
        [string]$RequesterEmail,
        [string]$TranscriptPath
    )

    $scriptPath = Join-Path $PSScriptRoot 'Invoke-PerformanceAudit.ps1'
    & $scriptPath @PSBoundParameters
}

Export-ModuleMember -Function 'Measure-STCommand','Invoke-PerformanceAudit'

function Show-PerformanceToolsBanner {
    <#
    .SYNOPSIS
        Returns PerformanceTools module metadata for banner display.
    #>
    [CmdletBinding()]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'PerformanceTools.psd1'
    [pscustomobject]@{
        Module  = 'PerformanceTools'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}
