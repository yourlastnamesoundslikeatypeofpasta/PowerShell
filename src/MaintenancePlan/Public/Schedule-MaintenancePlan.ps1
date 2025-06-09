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

    function Parse-CronField {
        param(
            [string]$Value,
            [int]$Min,
            [int]$Max,
            [string]$Name,
            [switch]$AllowStar,
            [switch]$AllowStep
        )
        if ($AllowStar -and $Value -eq '*') { return @{} }
        if ($AllowStep -and $Value -match '^\*/(\d+)$') {
            $step = [int]$Matches[1]
            if ($step -lt 1 -or $step -gt $Max) { throw "Cron $Name step must be between 1 and $Max" }
            return @{ Interval = $step }
        }
        if ($Value -notmatch '^\d+$') { throw "Cron $Name field must be an integer" }
        $num = [int]$Value
        if ($num -lt $Min -or $num -gt $Max) { throw "Cron $Name field must be between $Min and $Max" }
        return @{ Value = $num }
    }

    function Convert-Cron {
        param([string]$CronExpression)
        $parts = $CronExpression -split '\s+'
        if ($parts.Length -ne 5) {
            throw 'Cron expression must have 5 fields: minute hour day-of-month month day-of-week'
        }
        $minute = Parse-CronField $parts[0] 0 59 'minute'
        $hour   = Parse-CronField $parts[1] 0 23 'hour'
        $dom    = Parse-CronField $parts[2] 1 31 'day-of-month' -AllowStar -AllowStep
        $month  = Parse-CronField $parts[3] 1 12 'month' -AllowStar
        $dow    = Parse-CronField $parts[4] 0 7 'day-of-week' -AllowStar -AllowStep

        return [pscustomobject]@{
            Minute = $minute.Value
            Hour   = $hour.Value
            DayOfMonth = $dom.Value
            DayInterval = $dom.Interval
            Month  = $month.Value
            DayOfWeek = if ($dow.Value) { if ($dow.Value -eq 7) { 0 } else { $dow.Value } } else { $null }
            WeekInterval = $dow.Interval
        }
    }

    $modulePath = Join-Path (Split-Path $PSScriptRoot -Parent) 'MaintenancePlan.psd1'
    $command = "Import-Module '$modulePath'; `$plan = Import-MaintenancePlan -Path '$PlanPath'; Invoke-MaintenancePlan -Plan `$plan"

    $cronParts = Convert-Cron $Cron

    if ($IsWindows) {
        Write-STStatus "Registering scheduled task $Name" -Level INFO -Log
        $time = '{0:D2}:{1:D2}' -f $cronParts.Hour, $cronParts.Minute
        $action = New-ScheduledTaskAction -Execute 'pwsh' -Argument "-NoProfile -Command \"$command\""

        $triggerParams = @{ At = $time }
        if ($cronParts.DayOfWeek -ne $null -or $cronParts.WeekInterval) {
            $triggerParams.Weekly = $true
            if ($cronParts.DayOfWeek -ne $null) {
                $triggerParams.DaysOfWeek = [System.DayOfWeek]$cronParts.DayOfWeek
            }
            if ($cronParts.WeekInterval) {
                $triggerParams.WeeksInterval = $cronParts.WeekInterval
            }
        } elseif ($cronParts.DayOfMonth -ne $null -or $cronParts.Month -ne $null) {
            $triggerParams.Monthly = $true
            if ($cronParts.DayOfMonth -ne $null) {
                $triggerParams.DaysOfMonth = $cronParts.DayOfMonth
            }
            if ($cronParts.Month -ne $null) {
                $triggerParams.MonthsOfYear = $cronParts.Month
            }
            if ($cronParts.DayInterval) {
                $triggerParams.DaysInterval = $cronParts.DayInterval
            }
        } else {
            $triggerParams.Daily = $true
            if ($cronParts.DayInterval) {
                $triggerParams.DaysInterval = $cronParts.DayInterval
            }
        }

        $trigger = New-ScheduledTaskTrigger @triggerParams
        Register-ScheduledTask -TaskName $Name -Action $action -Trigger $trigger -Force | Out-Null
    } else {
        # validate cron on non-windows too
        $null = $cronParts
        $entry = "$Cron pwsh -NoProfile -Command \"$command\" # $Name"
        Write-STStatus "Cron entry generated" -Level INFO -Log
        return $entry
    }
}
