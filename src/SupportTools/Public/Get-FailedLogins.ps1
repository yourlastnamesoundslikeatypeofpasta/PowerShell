function Get-FailedLogins {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Get-FailedLogins.ps1" -Args $Arguments
    }
}
