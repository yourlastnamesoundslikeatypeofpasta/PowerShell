function Add-UsersToGroup {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$CsvPath,
        [Parameter(ValueFromPipelineByPropertyName=$true)]
        [string]$GroupName
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

        Invoke-ScriptFile -Name 'AddUsersToGroup.ps1' -Args $arguments
    }
}
