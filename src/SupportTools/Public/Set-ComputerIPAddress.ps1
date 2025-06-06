function Set-ComputerIPAddress {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Set-ComputerIPAddress.ps1" -Args $Arguments
    }
}
