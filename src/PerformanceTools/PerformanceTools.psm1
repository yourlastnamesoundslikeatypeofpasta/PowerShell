$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue

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

    Invoke-STSafe -OperationName 'Measure-STCommand' -ScriptBlock {
        $before = Get-Process -Id $PID
        $cpuStart = $before.TotalProcessorTime
        $memStart = $before.WorkingSet64

        $sw = [System.Diagnostics.Stopwatch]::StartNew()
        & $ScriptBlock
        $sw.Stop()

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

        return $result
    } -ThrowOnError:$false
}

Export-ModuleMember -Function 'Measure-STCommand'

function Show-PerformanceToolsBanner {
    Write-STDivider 'PERFORMANCETOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module PerformanceTools' to view available tools." -Level SUB
    Write-STLog -Message 'PerformanceTools module loaded'
}

Show-PerformanceToolsBanner
