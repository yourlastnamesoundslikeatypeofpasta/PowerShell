function Export-ProductKey {
    <#
    .SYNOPSIS
        Retrieves the Windows product key.
    .DESCRIPTION
        Executes the ProductKey.ps1 script located in the scripts directory.
        Any arguments are forwarded to that script.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath,
        [switch]$Simulate
    )
    process {
        Invoke-ScriptFile -Name "ProductKey.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate
    }
}
