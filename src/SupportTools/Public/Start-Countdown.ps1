function Start-Countdown {
    <#
    .SYNOPSIS
        Displays a countdown timer.
    .DESCRIPTION
        Executes the SimpleCountdown.ps1 script, passing through any provided
        arguments.
    #>
    [CmdletBinding()]
    param(
        [string]$TranscriptPath,
        [switch]$EnableTranscript,
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "SimpleCountdown.ps1" -TranscriptPath $TranscriptPath -EnableTranscript:$EnableTranscript -Args $Arguments
    }
}
