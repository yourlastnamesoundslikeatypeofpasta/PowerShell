function Submit-SystemInfoTicket {
    <#
    .SYNOPSIS
        Collect system info, upload it to SharePoint, and create a Service Desk ticket.
    .DESCRIPTION
        Wraps the Submit-SystemInfoTicket.ps1 script in the scripts folder with the supplied parameters.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$SiteName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$RequesterEmail,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Subject,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Description,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$FolderPath,
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
        $arguments = @('-SiteName', $SiteName, '-RequesterEmail', $RequesterEmail)
        if ($PSBoundParameters.ContainsKey('Subject'))     { $arguments += @('-Subject', $Subject) }
        if ($PSBoundParameters.ContainsKey('Description')) { $arguments += @('-Description', $Description) }
        if ($PSBoundParameters.ContainsKey('LibraryName')) { $arguments += @('-LibraryName', $LibraryName) }
        if ($PSBoundParameters.ContainsKey('FolderPath'))  { $arguments += @('-FolderPath', $FolderPath) }
        Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Submit-SystemInfoTicket.ps1' -Args $arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
