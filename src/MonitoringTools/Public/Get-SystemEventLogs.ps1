function Get-SystemEventLogs {
    <#
    .SYNOPSIS
        Retrieves recent system and application event log entries.
    .DESCRIPTION
        Queries the System and Application logs using Get-WinEvent and returns the latest events.
    .PARAMETER LogName
        Name of the log to query. Defaults to System.
    .PARAMETER MaxEvents
        Maximum number of events to return. Default 50.
    #>
    [CmdletBinding()]
    param(
        [ValidateNotNullOrEmpty()]
        [string]$LogName = 'System',
        [int]$MaxEvents = 50
    )
    process {
        try {
            Get-WinEvent -LogName $LogName -MaxEvents $MaxEvents | Select-Object TimeCreated, Id, LevelDisplayName, Message
        } catch {
            Write-STStatus "Get-SystemEventLogs failed: $_" -Level ERROR -Log
            return New-STErrorObject -Message $_.Exception.Message -Category 'EventLog'
        }
    }
}
