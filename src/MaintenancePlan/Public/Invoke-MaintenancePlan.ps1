function Invoke-MaintenancePlan {
    <#
    .SYNOPSIS
        Execute all steps in a maintenance plan.
    .PARAMETER Plan
        Plan object created by New-MaintenancePlan or Import-MaintenancePlan.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object]$Plan
    )
    Assert-ParameterNotNull $Plan 'Plan'
    foreach ($step in $Plan.Steps) {
        Write-STStatus "Running $step" -Level INFO -Log
        if ($PSCmdlet.ShouldProcess($step)) {
            if (Test-Path $step) {
                & $step
            } else {
                Invoke-Expression $step
            }
        }
    }
}
