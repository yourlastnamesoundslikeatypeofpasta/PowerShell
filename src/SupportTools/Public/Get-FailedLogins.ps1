function Get-FailedLogins {
    <#
    .SYNOPSIS
        Retrieves failed login attempts from the Security event log.
    .DESCRIPTION
        Calls the Get-FailedLogins.ps1 script in the scripts folder and returns
        its output.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Get-FailedLogins.ps1" -Args $Arguments
    }
}
