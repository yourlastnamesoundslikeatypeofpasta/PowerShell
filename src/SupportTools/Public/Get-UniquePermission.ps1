function Get-UniquePermission {
    <#
    .SYNOPSIS
        Returns items with unique permissions in a SharePoint site.
    .DESCRIPTION
        Calls the Get-UniquePermissions.ps1 script contained in the scripts
        directory and outputs its results.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath,
        [switch]$Simulate,
        [switch]$Explain
    )
    process {
        Invoke-STSafe -OperationName 'Get-UniquePermission' -ScriptBlock {
            Invoke-ScriptFile -Name "Get-UniquePermissions.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        }
    }
}
