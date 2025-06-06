function Set-NetAdapterMetering {
    <#
    .SYNOPSIS
        Toggles the metered connection flag on a network adapter.
    .DESCRIPTION
        Invokes the Set-NetAdapterMetering.ps1 script with any supplied
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
        Invoke-ScriptFile -Name "Set-NetAdapterMetering.ps1" -TranscriptPath $TranscriptPath -EnableTranscript:$EnableTranscript -Args $Arguments
    }
}
