function Add-UserToGroup {
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
        [switch]$Simulate,
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
        try {
            $arguments = @()
            if ($PSBoundParameters.ContainsKey('CsvPath')) {
                $arguments += '-CsvPath'
                $arguments += $CsvPath
            }
            if ($PSBoundParameters.ContainsKey('GroupName')) {
                $arguments += '-GroupName'
                $arguments += $GroupName
            }
            if ($PSBoundParameters.ContainsKey('Cloud')) {
                $arguments += '-Cloud'
                $arguments += $Cloud
            }

            if ($PSBoundParameters.ContainsKey('WhatIf')) {
                $arguments += '-WhatIf'
            }
            if ($PSBoundParameters.ContainsKey('Confirm')) {
                $arguments += '-Confirm'
            }

            Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'AddUsersToGroup.ps1' -Args $arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        } catch {
            return New-STErrorRecord -Message $_.Exception.Message -Exception $_.Exception
        }
    }
}
