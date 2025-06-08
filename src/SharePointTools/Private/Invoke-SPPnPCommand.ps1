function Invoke-SPPnPCommand {
    <#
    .SYNOPSIS
        Executes a PnP.PowerShell command with standardized error handling.
    .PARAMETER ScriptBlock
        The command to execute.
    .PARAMETER ErrorMessage
        Message logged when the command fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][scriptblock]$ScriptBlock,
        [string]$ErrorMessage = 'PnP command failed'
    )
    try {
        & $ScriptBlock
    } catch {
        Write-STStatus "${ErrorMessage}: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

