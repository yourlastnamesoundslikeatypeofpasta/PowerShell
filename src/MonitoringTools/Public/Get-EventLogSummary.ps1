function Get-EventLogSummary {
    <#
    .SYNOPSIS
        Summarises recent event log activity.
    .DESCRIPTION
        Returns counts of Error and Warning events from the specified log within the last N hours.
        Logs activity via Write-STRichLog.
    #>
    [CmdletBinding()]
    param(
        [string]$LogName = 'System',
        [int]$LastHours = 24
    )

    $computer = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { $env:HOSTNAME }
    $time = Get-Date -Format 'o'
    if (Get-Command Get-WinEvent -ErrorAction SilentlyContinue) {
        $events = Get-WinEvent -FilterHashtable @{ LogName = $LogName; StartTime = (Get-Date).AddHours(-$LastHours) }
        $summary = $events |
            Where-Object { $_.LevelDisplayName -in @('Error','Warning') } |
            Group-Object LevelDisplayName |
            Select-Object Name, Count
        Write-STRichLog -Tool 'Get-EventLogSummary' -Status 'success' -Details @("ComputerName=$computer","Timestamp=$time","Log=$LogName")
        $summary
    } elseif (Get-Command Get-EventLog -ErrorAction SilentlyContinue) {
        $events = Get-EventLog -LogName $LogName -After (Get-Date).AddHours(-$LastHours)
        $summary = $events |
            Where-Object { $_.EntryType -in 'Error','Warning' } |
            Group-Object EntryType |
            Select-Object Name, Count
        Write-STRichLog -Tool 'Get-EventLogSummary' -Status 'success' -Details @("ComputerName=$computer","Timestamp=$time","Log=$LogName")
        $summary
    } else {
        Write-Warning 'Event log cmdlets are not available.'
        Write-STRichLog -Tool 'Get-EventLogSummary' -Status 'error' -Details @("ComputerName=$computer","Timestamp=$time","Reason=Cmdlets unavailable")
        @()
    }
}
