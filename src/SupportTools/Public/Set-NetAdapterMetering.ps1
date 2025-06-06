function Set-NetAdapterMetering {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Set-NetAdapterMetering.ps1" -Args $Arguments
    }
}
