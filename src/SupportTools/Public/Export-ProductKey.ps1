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
        [string]$TranscriptPath,
        [switch]$EnableTranscript,
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "ProductKey.ps1" -TranscriptPath $TranscriptPath -EnableTranscript:$EnableTranscript -Args $Arguments
    }
}
