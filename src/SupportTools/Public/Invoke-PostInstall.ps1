function Invoke-PostInstall {
    <#
    .SYNOPSIS
        Executes the automated post installation script.
    .DESCRIPTION
        Runs PostInstallScript.ps1 from the scripts folder, forwarding any
        arguments provided.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath
    )
    process {
        Invoke-ScriptFile -Name "PostInstallScript.ps1" -Args $Arguments -TranscriptPath $TranscriptPath
    }
}
