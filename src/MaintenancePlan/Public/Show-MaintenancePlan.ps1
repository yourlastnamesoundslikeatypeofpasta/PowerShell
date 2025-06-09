function Show-MaintenancePlan {
    <#
    .SYNOPSIS
        Display a formatted summary of a maintenance plan.
    .PARAMETER Plan
        Plan object created by New-MaintenancePlan or Import-MaintenancePlan.
    #>
    [CmdletBinding(PositionalBinding = $false)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [ValidateNotNull()]
        [object]$Plan
    )
    process {
        Assert-ParameterNotNull $Plan 'Plan'
        Write-STDivider -Title 'MAINTENANCE PLAN' -Style heavy
        $summary = [ordered]@{
            Name     = $Plan.Name
            Steps    = ($Plan.Steps | Measure-Object).Count
            Schedule = if ($Plan.PSObject.Properties.Match('Schedule')) { $Plan.Schedule } else { '' }
        }
        Write-STBlock -Data $summary
        $index = 1
        foreach ($step in $Plan.Steps) {
            Write-STStatus -Message "$index. $step" -Level SUB
            $index++
        }
        Write-STClosing
    }
}
