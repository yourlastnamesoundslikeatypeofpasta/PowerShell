function Get-NetworkShares {
    <#
    .SYNOPSIS
        Lists network shares on a specified computer.
    .DESCRIPTION
        Executes the Get-NetworkShares.ps1 script from the scripts folder and
        returns its results.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Write-Debug "Get-NetworkShares wrapper calling script with args: $($Arguments -join ' ')"
        Invoke-ScriptFile -Name "Get-NetworkShares.ps1" -Args $Arguments
        Write-Debug "Get-NetworkShares wrapper completed"
    }
}
