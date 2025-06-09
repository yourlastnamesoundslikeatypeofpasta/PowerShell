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
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Name,
        [Parameter(Mandatory)]
        [ValidateNotNull()]
        [object[]]$Steps,
        [string]$Schedule
    )
    Assert-ParameterNotNull $Name 'Name'
    Assert-ParameterNotNull $Steps 'Steps'
    [pscustomobject]@{
        Name     = $Name
        Steps    = $Steps
        Schedule = $Schedule
    }
}
