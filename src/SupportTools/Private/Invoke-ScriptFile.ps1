function Invoke-ScriptFile {
    <#
    .SYNOPSIS
        Executes a script from the repository's scripts folder.
    .PARAMETER Name
        Name of the script file to execute.
    .PARAMETER TranscriptPath
        Optional log file path for Start-Transcript.
    .PARAMETER EnableTranscript
        Automatically create a transcript in the user's profile if set.
    .PARAMETER Args
        Additional arguments to pass to the script.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [string]$TranscriptPath,
        [switch]$EnableTranscript,
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Args
    )

    $Path = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath '..' | Join-Path -ChildPath "scripts/$Name"
    if (-not (Test-Path $Path)) { throw "Script '$Name' not found." }

    Write-Host "[***] EXECUTING $Name" -ForegroundColor Green -BackgroundColor Black
    if ($Args) {
        Write-Host "       ARGS: $($Args -join ' ')" -ForegroundColor DarkGreen -BackgroundColor Black
    }

    if ($EnableTranscript -or $TranscriptPath) {
        if (-not $TranscriptPath) {
            $TranscriptPath = Join-Path $env:USERPROFILE "${Name}_$(Get-Date -Format yyyyMMdd_HHmmss).log"
        }
        try {
            Start-Transcript -Path $TranscriptPath -Append | Out-Null
        } catch {
            Write-Warning "Failed to start transcript: $_"
        }
    }

    $oldPref = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    try {
        $result = & $Path @Args
    } catch {
        Write-Error "Execution of '$Name' failed: $_"
        throw
    } finally {
        $ErrorActionPreference = $oldPref
        if ($EnableTranscript -or $TranscriptPath) {
            try { Stop-Transcript | Out-Null } catch {}
            Write-Host "[***] Transcript saved to $TranscriptPath" -ForegroundColor DarkGreen -BackgroundColor Black
        }
    }

    Write-Host "[***] COMPLETED $Name" -ForegroundColor Green -BackgroundColor Black
    return $result
}
