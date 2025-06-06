function Install-MaintenanceTasks {
    <#
    .SYNOPSIS
        Registers weekly maintenance scheduled tasks.
    .DESCRIPTION
        Wraps the Setup-ScheduledMaintenance.ps1 script which generates Task Scheduler XML
        and optionally registers the tasks. Parameters are passed directly through.
    .PARAMETER Register
        If set, tasks are registered immediately; otherwise XML files are created.
    #>
    [CmdletBinding()]
    param(
        [switch]$Register,
        [string]$TranscriptPath
        [switch]$Simulate
    )
    process {
        $argsList = @()
        if ($Register) { $argsList += '-Register' }
        Invoke-ScriptFile -Name 'Setup-ScheduledMaintenance.ps1' -Args $argsList -TranscriptPath $TranscriptPath -Simulate:$Simulate
    }
}
