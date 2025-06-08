function Invoke-MaintenancePlan {
    <#
    .SYNOPSIS
        Execute all steps in a maintenance plan.
    .PARAMETER Plan
        Plan object created by New-MaintenancePlan or Import-MaintenancePlan.
    .PARAMETER WhatIf
        Display commands without executing.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Plan,
        [switch]$WhatIf
    )
    Assert-ParameterNotNull $Plan 'Plan'
    foreach ($step in $Plan.Steps) {
        Write-STStatus "Running $step" -Level INFO -Log
        if (-not $WhatIf) {
            if (Test-Path $step) {
                & $step
            } else {
                Invoke-Expression $step
            }
        }
    }
}
