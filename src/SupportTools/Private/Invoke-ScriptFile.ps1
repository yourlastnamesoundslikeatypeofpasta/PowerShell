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
        [object[]]$Args,
        [string]$TranscriptPath
    )
    $Path = Join-Path $PSScriptRoot '..' |
            Join-Path -ChildPath '..' |
            Join-Path -ChildPath '..' |
            Join-Path -ChildPath "scripts/$Name"
    if (-not (Test-Path $Path)) { throw "Script '$Name' not found." }

    Write-Host "[***] EXECUTING $Name" -ForegroundColor Green -BackgroundColor Black
    Write-STLog "EXECUTING $Name"
    if ($Args) {
        Write-Host "       ARGS: $($Args -join ' ')" -ForegroundColor DarkGreen -BackgroundColor Black
        Write-STLog "ARGS: $($Args -join ' ')"
    }

    if ($TranscriptPath) {
        Start-Transcript -Path $TranscriptPath -Append | Out-Null
    }

    $oldPref = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    try {
        & $Path @Args
    } catch {
        Write-Error "Execution of '$Name' failed: $_"
        Write-STLog "Execution of '$Name' failed: $_" -Level 'ERROR'
        throw
    } finally {
        $ErrorActionPreference = $oldPref
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
    Write-Host "[***] COMPLETED $Name" -ForegroundColor Green -BackgroundColor Black
    Write-STLog "COMPLETED $Name"
}
