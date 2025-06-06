function Invoke-ScriptFile {
    <#
    .SYNOPSIS
        Executes a script from the repository's scripts folder.
    .PARAMETER Name
        Name of the script file to execute.
    .PARAMETER Args
        Additional arguments to pass to the script.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Args
    )
    $Path = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath '..' | Join-Path -ChildPath "scripts/$Name"
    Write-Debug "Invoke-ScriptFile resolved path '$Path'"
    if (-not (Test-Path $Path)) { throw "Script '$Name' not found." }

    Write-Host "[***] EXECUTING $Name" -ForegroundColor Green -BackgroundColor Black
    if ($Args) {
        Write-Host "       ARGS: $($Args -join ' ')" -ForegroundColor DarkGreen -BackgroundColor Black
    }

    Write-Debug "Invoking script '$Name' with args: $($Args -join ' ')"
    & $Path @Args
    Write-Debug "Script '$Name' finished"

    Write-Host "[***] COMPLETED $Name" -ForegroundColor Green -BackgroundColor Black
}
