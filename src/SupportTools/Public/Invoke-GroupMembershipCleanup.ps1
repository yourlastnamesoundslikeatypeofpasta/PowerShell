function Invoke-GroupMembershipCleanup {
    <#
    .SYNOPSIS
        Removes users from a Microsoft 365 group.
    .DESCRIPTION
        Wraps the CleanupGroupMembership.ps1 script located in the scripts folder.
    .PARAMETER CsvPath
        Path to the CSV file containing user principal names.
    .PARAMETER GroupName
        Name of the Microsoft 365 group to modify.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$CsvPath,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$GroupName,
        [string]$TranscriptPath,
        [switch]$Explain,
        [object]$Logger,
        [object]$TelemetryClient,
        [object]$Config
    )
    process {
        $arguments = @()
        if ($PSBoundParameters.ContainsKey('CsvPath')) { $arguments += '-CsvPath'; $arguments += $CsvPath }
        if ($PSBoundParameters.ContainsKey('GroupName')) { $arguments += '-GroupName'; $arguments += $GroupName }
        Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'CleanupGroupMembership.ps1' -Args $arguments -TranscriptPath $TranscriptPath -Explain:$Explain
    }
}
