function Update-Sysmon {
    <#
    .SYNOPSIS
        Updates the Sysmon installation on a computer.
    .DESCRIPTION
        Calls the Update-Sysmon.ps1 script with the supplied arguments.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Update-Sysmon.ps1" -Args $Arguments
    }
}
