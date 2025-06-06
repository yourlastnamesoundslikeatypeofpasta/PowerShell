function Update-Sysmon {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Update-Sysmon.ps1" -Args $Arguments
    }
}
