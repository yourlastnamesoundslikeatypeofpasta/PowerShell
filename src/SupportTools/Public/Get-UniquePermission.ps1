function Get-UniquePermission {
    <#
    .SYNOPSIS
        Returns items with unique permissions in a SharePoint site.
    .DESCRIPTION
        Calls the Get-UniquePermissions.ps1 script contained in the scripts
        directory and outputs its results.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $false, ValueFromRemainingArguments = $true, ValueFromPipeline = $true)]
        [object[]]$Arguments,
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
        try {
            $output = Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name "Get-UniquePermissions.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        } catch {
            Write-Error $_.Exception.Message
            throw
        }
        return [pscustomobject]@{
            Script = 'Get-UniquePermissions.ps1'
            Result = $output
        }
    }
}
