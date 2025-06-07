function Install-Font {
    <#
    .SYNOPSIS
        Installs font files for all users.
    .DESCRIPTION
        Simple wrapper for the Install-Fonts.ps1 script which performs the
        installation work. Arguments are passed directly through.
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
        Invoke-ScriptFile -Name "Install-Fonts.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
