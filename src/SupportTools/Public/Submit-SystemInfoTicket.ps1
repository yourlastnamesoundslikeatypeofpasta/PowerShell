function Submit-SystemInfoTicket {
    <#
    .SYNOPSIS
        Collect system info, upload it to SharePoint, and create a Service Desk ticket.
    .DESCRIPTION
        Wraps the Submit-SystemInfoTicket.ps1 script in the scripts folder with the supplied parameters.
    #>
    [CmdletBinding()]
    param(
        [string]$SiteName,
        [string]$RequesterEmail,
        [string]$Subject,
        [string]$Description,
        [string]$LibraryName,
        [string]$FolderPath,
        [string]$TranscriptPath,
        [switch]$Simulate
    )
    process {
        $arguments = @('-SiteName', $SiteName, '-RequesterEmail', $RequesterEmail)
        if ($PSBoundParameters.ContainsKey('Subject'))     { $arguments += @('-Subject', $Subject) }
        if ($PSBoundParameters.ContainsKey('Description')) { $arguments += @('-Description', $Description) }
        if ($PSBoundParameters.ContainsKey('LibraryName')) { $arguments += @('-LibraryName', $LibraryName) }
        if ($PSBoundParameters.ContainsKey('FolderPath'))  { $arguments += @('-FolderPath', $FolderPath) }
        Invoke-ScriptFile -Name 'Submit-SystemInfoTicket.ps1' -Args $arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate
    }
}
