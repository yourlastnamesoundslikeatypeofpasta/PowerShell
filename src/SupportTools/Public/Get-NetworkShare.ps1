function Get-NetworkShare {
    <#
    .SYNOPSIS
        Lists network shares on a specified computer.
    .DESCRIPTION
        Executes the Get-NetworkShares.ps1 script from the scripts folder and
        returns its results.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath
        [switch]$Simulate
    )
    process {
        Invoke-ScriptFile -Name "Get-NetworkShares.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate
    }
}
