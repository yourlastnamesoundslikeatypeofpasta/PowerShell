$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $telemetryModule -ErrorAction SilentlyContinue

function Invoke-ChaosTest {
    <#
    .SYNOPSIS
        Run randomized delays and optional failures for resilience testing.
    .DESCRIPTION
        Generates pauses and randomly throws errors when `-ChaosMode` or the `ST_CHAOS_MODE` environment variable is set. Use to validate retry logic and monitoring alerts.
    .PARAMETER Iterations
        Number of iterations to execute.
    .PARAMETER MaxDelaySeconds
        Maximum delay in seconds for each iteration.
    .PARAMETER FailureRate
        Percent chance of throwing an error each iteration.
    .PARAMETER ChaosMode
        Force chaos behavior regardless of environment variable.
    .EXAMPLE
        Invoke-ChaosTest -Iterations 3 -MaxDelaySeconds 2 -FailureRate 10

        Run three cycles with up to two seconds delay and a 10% failure chance.
    #>
    [CmdletBinding()]
    param(
        [int]$Iterations = 5,
        [int]$MaxDelaySeconds = 5,
        [int]$FailureRate = 20,
        [switch]$ChaosMode
    )
    if (-not $ChaosMode) { $ChaosMode = [bool]$env:ST_CHAOS_MODE }
    for ($i = 1; $i -le $Iterations; $i++) {
        $delayMs = Get-Random -Minimum 100 -Maximum ($MaxDelaySeconds * 1000)
        Write-STStatus "[>] Iteration $i delaying $delayMs ms" -Level SUB -Log
        Start-Sleep -Milliseconds $delayMs
        if ($ChaosMode -and (Get-Random -Minimum 1 -Maximum 100) -le $FailureRate) {
            Write-STLog -Message "Chaos failure at iteration $i" -Level ERROR -Structured
            throw "ChaosMode failure during iteration $i"
        }
    }
    Write-STStatus 'Chaos test completed' -Level FINAL -Log
}

Export-ModuleMember -Function 'Invoke-ChaosTest'

function Show-ChaosBanner {
    Write-STDivider 'CHAOSTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Invoke-ChaosTest' to begin fault injection." -Level SUB
    Write-STLog -Message 'ChaosTools module loaded'
}

Show-ChaosBanner
