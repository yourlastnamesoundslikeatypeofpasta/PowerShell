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

    Use-STTranscript -Path $TranscriptPath -ScriptBlock {
        try {
            foreach ($num in 10..1) {
                Write-STStatus $num -Level INFO
                Start-Sleep -Seconds 1
            }
            return [pscustomobject]@{
                CountdownFrom = 10
                Completed     = $true
            }
        } catch {
            return New-STErrorRecord -Message $_.Exception.Message -Exception $_.Exception
        }
    }
}
