function Invoke-NewHireUserAutomation {
    <#
    .SYNOPSIS
        Creates Entra ID users based on new hire Service Desk tickets.
    .DESCRIPTION
        Wraps the Create-NewHireUser.ps1 script in the scripts folder with the provided parameters.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$false)]
        [int]$PollMinutes = 5,
        [Parameter(Mandatory=$false)]
        [switch]$Once,
        [Parameter(Mandatory=$false)]
        [string]$TranscriptPath,
        [Parameter(Mandatory=$false)]
        [switch]$Simulate,
        [Parameter(Mandatory=$false)]
        [switch]$Explain,
        [Parameter(Mandatory=$false)]
        [object]$Logger,
        [Parameter(Mandatory=$false)]
        [object]$TelemetryClient,
        [Parameter(Mandatory=$false)]
        [object]$Config
    )
    process {
        try {
            $args = @('-PollMinutes', $PollMinutes)
            if ($Once) { $args += '-Once' }
            if ($PSBoundParameters.ContainsKey('TranscriptPath')) { $args += '-TranscriptPath'; $args += $TranscriptPath }
            Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Create-NewHireUser.ps1' -Args $args -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        } catch {
            return New-STErrorRecord -Message $_.Exception.Message -Exception $_.Exception
        }
    }
}
