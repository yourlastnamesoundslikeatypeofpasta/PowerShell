function Invoke-ChaosTest {
    <#
    .SYNOPSIS
        Executes a script block with random failures.
    .DESCRIPTION
        Runs the given commands and randomly throws an error based on FailureRate.
        A random delay up to MaxDelaySeconds is introduced before execution. Set
        the CHAOSTOOLS_ENABLED environment variable to 0 or False to execute
        the script block without any injected failures or delays.
    .PARAMETER ScriptBlock
        Commands to invoke.
    .PARAMETER FailureRate
        Probability from 0 to 1 of injecting a failure.
    .PARAMETER MaxDelaySeconds
        Maximum random delay before execution.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [scriptblock]$ScriptBlock,
        [ValidateRange(0,1)]
        [double]$FailureRate = 0.3,
        [ValidateRange(0,60)]
        [int]$MaxDelaySeconds = 5
    )

    Assert-ParameterNotNull $ScriptBlock 'ScriptBlock'
    if ($FailureRate -lt 0 -or $FailureRate -gt 1) {
        throw 'FailureRate must be between 0 and 1.'
    }
    $chaosEnabledVar = $env:CHAOSTOOLS_ENABLED
    if ($chaosEnabledVar -ne $null -and $chaosEnabledVar -match '^(0|False)$') {
        Write-STStatus 'ChaosTools disabled via CHAOSTOOLS_ENABLED.' -Level INFO -Log
        & $ScriptBlock
        return
    }

    if ($MaxDelaySeconds -gt 0) {
        $delay = Get-Random -Minimum 0 -Maximum ($MaxDelaySeconds + 1)
        Start-Sleep -Seconds $delay
    }

    $threshold = [int]([int]::MaxValue * $FailureRate)
    $rand = Get-Random
    if ($rand -lt $threshold) {
        Write-STStatus 'Chaos failure injected.' -Level ERROR -Log
        throw 'Chaos test failure.'
    }

    Write-STStatus 'Executing chaos test script block.' -Level INFO -Log
    & $ScriptBlock
}
