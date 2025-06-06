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
    if (-not (Test-Path $Path)) { throw "Script '$Name' not found." }
    & $Path @Args
}
