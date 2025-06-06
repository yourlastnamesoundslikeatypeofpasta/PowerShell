function Install-Fonts {
    <#
    .SYNOPSIS
        Installs font files for all users.
    .DESCRIPTION
        Simple wrapper for the Install-Fonts.ps1 script which performs the
        installation work. Arguments are passed directly through.
    #>
    [CmdletBinding()]
    param(
        [string]$TranscriptPath,
        [switch]$EnableTranscript,
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Install-Fonts.ps1" -TranscriptPath $TranscriptPath -EnableTranscript:$EnableTranscript -Args $Arguments
    }
}
