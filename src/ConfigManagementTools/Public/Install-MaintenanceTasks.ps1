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
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory = $false)]
        [switch]$Register,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath,
        [Parameter(Mandatory = $false)]
        [switch]$Simulate,
        [Parameter(Mandatory = $false)]
        [switch]$Explain,
        [Parameter(Mandatory = $false)]
        [object]$Logger,
        [Parameter(Mandatory = $false)]
        [object]$TelemetryClient,
        [Parameter(Mandatory = $false)]
        [object]$Config
    )
    process {
        $argsList = @()
        if ($Register) { $argsList += '-Register' }
        Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Setup-ScheduledMaintenance.ps1' -Args $argsList -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
