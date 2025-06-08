function Start-Countdown {
    <#
    .SYNOPSIS
        Displays a countdown timer.
    .DESCRIPTION
        Writes numbers from 10 down to 1 with a one second delay between
        each number. Useful for short pauses in scripts.
    #>
    [CmdletBinding()]
    param()

    foreach ($num in 10..1) {
        Write-STStatus $num -Level INFO
        Start-Sleep -Seconds 1
    }
}
