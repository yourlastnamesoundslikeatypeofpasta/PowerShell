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

    Write-STStatus "EXECUTING $Name" -Level SUCCESS -Log
    if ($Args) {
        Write-STStatus "ARGS: $($Args -join ' ')" -Level SUB -Log
    }

    if ($TranscriptPath) {
        Start-Transcript -Path $TranscriptPath -Append | Out-Null
    }

    $start = Get-Date
    $result = 'Success'
    $oldPref = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    try {
        & $Path @Args
    } catch {
        Write-Error "Execution of '$Name' failed: $_"
        Write-STLog "Execution of '$Name' failed: $_" -Level 'ERROR'
        $result = 'Failure'
        throw
    } finally {
        $ErrorActionPreference = $oldPref
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
        $duration = (Get-Date) - $start
        Write-STTelemetryEvent -ScriptName $Name -Result $result -Duration $duration
    }
    Write-STStatus "COMPLETED $Name" -Level FINAL -Log
}
