function Start-Countdown {
    <#
    .SYNOPSIS
        Displays a countdown timer.
    .DESCRIPTION
        Writes numbers from 10 down to 1 with a one second delay between
        each number. Useful for short pauses in scripts.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath
    )

    try {
        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append -ErrorAction Stop | Out-Null }

        foreach ($num in 10..1) {
            Write-STStatus $num -Level INFO
            Start-Sleep -Seconds 1
        }
        return [pscustomobject]@{
            CountdownFrom = 10
            Completed     = $true
        }
    } catch {
        Write-STLog -Message $_.Exception.Message -Level ERROR
        throw
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}
