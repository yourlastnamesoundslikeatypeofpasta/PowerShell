function Add-UsersToGroup {
    <#
    .SYNOPSIS
        Adds users from a CSV file to a Microsoft 365 group.
    .DESCRIPTION
        Wraps the AddUsersToGroup.ps1 script located in the repository's scripts
        folder. Parameters are passed directly through to the script file.
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
        [switch]$EnableTranscript
    )

    process {
        $arguments = @()
        if ($PSBoundParameters.ContainsKey('CsvPath')) {
            $arguments += '-CsvPath'
            $arguments += $CsvPath
        }
        if ($PSBoundParameters.ContainsKey('GroupName')) {
            $arguments += '-GroupName'
            $arguments += $GroupName
        }

        Invoke-ScriptFile -Name 'AddUsersToGroup.ps1' -TranscriptPath $TranscriptPath -EnableTranscript:$EnableTranscript -Args $arguments
    }
}
