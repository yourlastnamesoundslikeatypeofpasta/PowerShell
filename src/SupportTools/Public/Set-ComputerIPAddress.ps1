function Set-ComputerIPAddress {
    <#
    .SYNOPSIS
        Configures the IP address of a local or remote computer.
    .DESCRIPTION
        Wraps the Set-ComputerIPAddress.ps1 script, forwarding all arguments.
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
        Invoke-ScriptFile -Name "Set-ComputerIPAddress.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
    }
}
