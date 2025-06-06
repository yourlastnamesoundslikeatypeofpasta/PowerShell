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
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath
    )
    process {
        Invoke-ScriptFile -Name "SimpleCountdown.ps1" -Args $Arguments -TranscriptPath $TranscriptPath
    }
}
