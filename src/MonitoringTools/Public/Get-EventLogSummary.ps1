function Get-EventLogSummary {
    <#
    .SYNOPSIS
        Summarises recent event log activity.
    .DESCRIPTION
        Returns counts of Error and Warning events from the specified log within the last N hours.
        A structured log entry summarising the results is written.
    #>
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$LogName = 'System',
        [ValidateRange(1,720)]
        [int]$LastHours = 24
    )

    $computer = Get-STComputerName
    $timestamp = (Get-Date).ToString('o')
    $summary = @()
    if (Get-Command Get-WinEvent -ErrorAction SilentlyContinue) {
        $events = Get-WinEvent -FilterHashtable @{ LogName = $LogName; StartTime = (Get-Date).AddHours(-$LastHours) }
        $summary = $events |
            Where-Object { $_.LevelDisplayName -in @('Error','Warning') } |
            Group-Object LevelDisplayName |
            Select-Object Name, Count
    } elseif (Get-Command Get-EventLog -ErrorAction SilentlyContinue) {
        $events = Get-EventLog -LogName $LogName -After (Get-Date).AddHours(-$LastHours)
        $summary = $events |
            Where-Object { $_.EntryType -in 'Error','Warning' } |
            Group-Object EntryType |
            Select-Object Name, Count
    } else {
        Write-Warning 'Event log cmdlets are not available.'
    }
    if (-not $summary) { $summary = @() }
    $json = @{ ComputerName = $computer; Timestamp = $timestamp; Summary = $summary } | ConvertTo-Json -Compress
    Write-STRichLog -Tool 'Get-EventLogSummary' -Status 'queried' -Details $json
    return $summary
}
