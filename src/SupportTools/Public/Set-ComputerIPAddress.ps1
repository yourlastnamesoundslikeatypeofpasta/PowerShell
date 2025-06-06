function Set-ComputerIPAddress {
    <#
    .SYNOPSIS
        Configures the IP address of a local or remote computer.
    .DESCRIPTION
        Wraps the Set-ComputerIPAddress.ps1 script, forwarding all arguments.
    #>
    [CmdletBinding()]
    param(
        [string]$TranscriptPath,
        [switch]$EnableTranscript,
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Set-ComputerIPAddress.ps1" -TranscriptPath $TranscriptPath -EnableTranscript:$EnableTranscript -Args $Arguments
    }
}
