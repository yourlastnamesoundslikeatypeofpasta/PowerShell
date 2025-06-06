function Get-CommonSystemInfo {
    <#
    .SYNOPSIS
        Returns common system information such as OS and hardware details.
    .DESCRIPTION
        Wraps the Get-CommonSystemInfo.ps1 script in the scripts folder and
        forwards any provided arguments.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments,
        [string]$TranscriptPath
        [switch]$Simulate
    )
    process {
        Invoke-ScriptFile -Name "Get-CommonSystemInfo.ps1" -Args $Arguments -TranscriptPath $TranscriptPath -Simulate:$Simulate
    }
}
