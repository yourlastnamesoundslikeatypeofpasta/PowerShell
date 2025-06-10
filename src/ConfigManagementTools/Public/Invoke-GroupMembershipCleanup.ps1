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
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$CsvPath,
        [Parameter(Mandatory = $true, ValueFromPipelineByPropertyName = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupName,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath,
        [Parameter(Mandatory = $false)]
        [switch]$Explain,
        [Parameter(Mandatory = $false)]
        [object]$Logger,
        [Parameter(Mandatory = $false)]
        [object]$TelemetryClient,
        [Parameter(Mandatory = $false)]
        [ValidateSet('Entra','AD')]
        [string]$Cloud = 'Entra',
        [Parameter(Mandatory = $false)]
        [object]$Config
    )
    process {
        $arguments = @()
        if ($PSBoundParameters.ContainsKey('CsvPath')) { $arguments += '-CsvPath'; $arguments += $CsvPath }
        if ($PSBoundParameters.ContainsKey('GroupName')) { $arguments += '-GroupName'; $arguments += $GroupName }
        if ($PSBoundParameters.ContainsKey('Cloud')) { $arguments += '-Cloud'; $arguments += $Cloud }
        if ($PSCmdlet.ShouldProcess($GroupName, 'Cleanup membership')) {
            Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'CleanupGroupMembership.ps1' -Args $arguments -TranscriptPath $TranscriptPath -Explain:$Explain
        }
    }
}
