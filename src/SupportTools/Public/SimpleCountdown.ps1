function SimpleCountdown {
<#
.SYNOPSIS
Display a simple countdown.

.DESCRIPTION
Writes numbers from 10 down to 1 with a one second delay between each
number. Useful for scripts that need a brief pause or countdown.
#>

    foreach ($num in 10..1) {
        Write-Information -MessageData $num -InformationAction Continue
        Start-Sleep -Seconds 1
    }
}
