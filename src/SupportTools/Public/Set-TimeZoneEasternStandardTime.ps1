function Set-TimeZoneEasternStandardTime {
    <#
    .SYNOPSIS
        Sets the system time zone to Eastern Standard Time.
    .DESCRIPTION
        Runs the Set-TimeZoneEasternStandardTime.ps1 script with any supplied
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
        Invoke-STSafe -OperationName 'Set-TimeZoneEasternStandardTime' -ScriptBlock {
            Invoke-ScriptFile -Name "Set-TimeZoneEasternStandardTime.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        }
    }
}
