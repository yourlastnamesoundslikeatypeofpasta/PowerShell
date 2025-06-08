function New-MaintenancePlan {
    <#
    .SYNOPSIS
        Create a new maintenance plan object.
    .DESCRIPTION
        Returns an object describing the plan which can be exported to JSON.
    .PARAMETER Name
        Name of the maintenance plan.
    .PARAMETER Steps
        Array of function calls or script paths to execute.
    .PARAMETER Schedule
        Optional description of the schedule.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][object[]]$Steps,
        [string]$Schedule
    )
    Assert-ParameterNotNull $Name 'Name'
    Assert-ParameterNotNull $Steps 'Steps'
    [pscustomobject]@{
        Name = $Name
        Steps = $Steps
        Schedule = $Schedule
    }
}
