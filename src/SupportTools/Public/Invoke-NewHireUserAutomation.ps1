function Invoke-NewHireUserAutomation {
    <#
    .SYNOPSIS
        Creates Entra ID users based on new hire Service Desk tickets.

    .DESCRIPTION
        Wraps the `Create-NewHireUser.ps1` script in the `scripts` folder with
        the provided parameters and polls the ticket queue for new requests.

    .PARAMETER PollMinutes
        Interval in minutes between polling the Service Desk for new hire
        tickets. Defaults to 5.

    .PARAMETER Once
        Process outstanding tickets once and then exit.

    .PARAMETER TranscriptPath
        Optional path for a transcript log.

    .PARAMETER Simulate
        Perform a dry run without creating any accounts.

    .PARAMETER Explain
        Display the help for `Create-NewHireUser.ps1`.

    .PARAMETER Logger
        Optional instance of the Logging module used for output.

    .PARAMETER TelemetryClient
        Optional telemetry client used to record metrics.

    .PARAMETER Config
        Optional configuration object injected into the script.

    .EXAMPLE
        Invoke-NewHireUserAutomation -Once -TranscriptPath ./newhire.log

        Processes any pending new hire tickets a single time and logs actions to
        `newhire.log`.

    .NOTES
        Requires permissions to create users in Entra ID and access the Service
        Desk API.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$false)]
        [ValidateRange(1,60)]
        [int]$PollMinutes = 5,
        [Parameter(Mandatory=$false)]
        [switch]$Once,
        [Parameter(Mandatory=$false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath,
        [Parameter(Mandatory=$false)]
        [switch]$Simulate,
        [Parameter(Mandatory=$false)]
        [switch]$Explain,
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [object]$Logger,
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [object]$TelemetryClient,
        [Parameter(Mandatory=$false)]
        [ValidateNotNull()]
        [object]$Config
    )
    process {
        try {
            $args = @('-PollMinutes', $PollMinutes)
            if ($Once) { $args += '-Once' }
            if ($PSBoundParameters.ContainsKey('TranscriptPath')) { $args += '-TranscriptPath'; $args += $TranscriptPath }
            if ($PSCmdlet.ShouldProcess('Create-NewHireUser.ps1')) {
                Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Create-NewHireUser.ps1' -Args $args -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
            }
        } catch {
            return New-STErrorRecord -Message $_.Exception.Message -Exception $_.Exception
        }
    }
}
