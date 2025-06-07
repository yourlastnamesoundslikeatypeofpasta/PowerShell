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
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath,
        [switch]$Simulate,
        [switch]$Explain
    )
    process {
        Invoke-ScriptFile -Name "Set-NetAdapterMetering.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
