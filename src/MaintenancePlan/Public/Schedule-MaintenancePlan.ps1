function Schedule-MaintenancePlan {
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
        Schedule-MaintenancePlan -PlanPath plan.json -Cron '0 3 * * 0' -Name Weekly
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

        $minute = [int]$parts[0]
        $hour   = [int]$parts[1]
        $time = '{0:D2}:{1:D2}' -f $hour, $minute

        $triggerArgs = @{ At = $time }
        if ($parts.Length -ge 3 -and $parts[2] -ne '*') {
            $triggerArgs.DaysOfMonth = $parts[2] -split ',' | ForEach-Object {[int]$_}
        }
        if ($parts.Length -ge 4 -and $parts[3] -ne '*') {
            $triggerArgs.MonthsOfYear = $parts[3] -split ',' | ForEach-Object {[int]$_}
        }
        if ($parts.Length -ge 5 -and $parts[4] -ne '*') {
            $triggerArgs.DaysOfWeek = $parts[4] -split ',' | ForEach-Object {
                switch ($_)
                {
                    '0' { 'Sunday' }
                    '1' { 'Monday' }
                    '2' { 'Tuesday' }
                    '3' { 'Wednesday' }
                    '4' { 'Thursday' }
                    '5' { 'Friday' }
                    '6' { 'Saturday' }
                    '7' { 'Sunday' }
                    default { $_ }
                }
            }
        }

        if ($triggerArgs.ContainsKey('DaysOfMonth') -or $triggerArgs.ContainsKey('MonthsOfYear')) {
            $trigger = New-ScheduledTaskTrigger -Monthly @triggerArgs
        } elseif ($triggerArgs.ContainsKey('DaysOfWeek')) {
            $trigger = New-ScheduledTaskTrigger -Weekly @triggerArgs
        } else {
            $trigger = New-ScheduledTaskTrigger -Daily @triggerArgs
        }

        $action  = New-ScheduledTaskAction -Execute 'pwsh' -Argument "-NoProfile -Command \"$command\""
        try {
            Register-ScheduledTask -TaskName $Name -Action $action -Trigger $trigger -Force | Out-Null
        } catch {
            Write-STStatus "Failed registering scheduled task $Name: $_" -Level ERROR -Log
        }
    } else {
        $entry = "$Cron pwsh -NoProfile -Command \"$command\" # $Name"
        Write-STStatus "Cron entry generated" -Level INFO -Log
        return $entry
    }
}
