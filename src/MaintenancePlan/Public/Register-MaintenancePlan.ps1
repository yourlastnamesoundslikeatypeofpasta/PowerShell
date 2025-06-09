# Original name: Schedule-MaintenancePlan
function Register-MaintenancePlan {
    <#
    .SYNOPSIS
        Schedule execution of a maintenance plan.
    .DESCRIPTION
        On Windows a scheduled task is registered. On Linux/macOS a cron
        entry is generated and returned.
    .PARAMETER PlanPath
        Path to the maintenance plan JSON file.
    .PARAMETER Cron
        Cron expression describing when the plan runs.
    .PARAMETER Name
        Name for the scheduled task or cron job.
    .EXAMPLE
        Register-MaintenancePlan -PlanPath plan.json -Cron '0 3 * * 0' -Name Weekly
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$PlanPath,
        [Parameter(Mandatory)][string]$Cron,
        [string]$Name = 'MaintenancePlan'
    )

    Assert-ParameterNotNull $PlanPath 'PlanPath'
    Assert-ParameterNotNull $Cron 'Cron'

    $modulePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'MaintenancePlan.psd1'
    $command = "Import-Module '$modulePath'; `$plan = Import-MaintenancePlan -Path '$PlanPath'; Invoke-MaintenancePlan -Plan `$plan"

    if ($IsWindows) {
        Write-STStatus "Registering scheduled task $Name" -Level INFO -Log
        $parts = $Cron -split '\s+'
        if ($parts.Length -lt 2) { throw 'Cron expression must include minute and hour' }
        $time = '{0:D2}:{1:D2}' -f [int]$parts[1], [int]$parts[0]
        $action  = New-ScheduledTaskAction -Execute 'pwsh' -Argument "-NoProfile -Command \"$command\""
        $trigger = New-ScheduledTaskTrigger -Daily -At $time
        Register-ScheduledTask -TaskName $Name -Action $action -Trigger $trigger -Force | Out-Null
    } else {
        $entry = "$Cron pwsh -NoProfile -Command \"$command\" # $Name"
        Write-STStatus "Cron entry generated" -Level INFO -Log
        return $entry
    }
}
