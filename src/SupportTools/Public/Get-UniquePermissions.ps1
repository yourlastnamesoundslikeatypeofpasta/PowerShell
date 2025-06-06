function Get-UniquePermissions {
    <#
    .SYNOPSIS
        Returns items with unique permissions in a SharePoint site.
    .DESCRIPTION
        Calls the Get-UniquePermissions.ps1 script contained in the scripts
        directory and outputs its results.
    #>
    [CmdletBinding()]
    param(
        [string]$TranscriptPath,
        [switch]$EnableTranscript,
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Get-UniquePermissions.ps1" -TranscriptPath $TranscriptPath -EnableTranscript:$EnableTranscript -Args $Arguments
    }
}
