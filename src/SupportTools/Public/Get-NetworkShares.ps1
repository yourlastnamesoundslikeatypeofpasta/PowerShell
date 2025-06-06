function Get-NetworkShares {
    <#
    .SYNOPSIS
        Lists network shares on a specified computer.
    .DESCRIPTION
        Executes the Get-NetworkShares.ps1 script from the scripts folder and
        returns its results.
    #>
    [CmdletBinding()]
    param(
        [string]$TranscriptPath,
        [switch]$EnableTranscript,
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Get-NetworkShares.ps1" -TranscriptPath $TranscriptPath -EnableTranscript:$EnableTranscript -Args $Arguments
    }
}
