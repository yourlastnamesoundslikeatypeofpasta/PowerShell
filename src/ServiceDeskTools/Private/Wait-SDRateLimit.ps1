function Wait-SDRateLimit {
    [CmdletBinding()]
    param(
        [int]$RateLimit
    )
    if (-not $RateLimit) { return }
    if (-not $script:SDRequestHistory) {
        $script:SDRequestHistory = [System.Collections.Generic.Queue[datetime]]::new()
    }

    $now = Get-Date

    while ($script:SDRequestHistory.Count -gt 0 -and $script:SDRequestHistory.Peek() -le $now.AddMinutes(-1)) {
        $null = $script:SDRequestHistory.Dequeue()
    }

    if ($script:SDRequestHistory.Count -ge $RateLimit) {
        $oldest = $script:SDRequestHistory.Peek()
        if ($oldest) {
            $wait = 60 - ($now - $oldest).TotalSeconds
            if ($wait -gt 0) {
                Write-Verbose "Rate limit reached, pausing for $wait seconds"
                Start-Sleep -Seconds [math]::Ceiling($wait)
            }
        }
    }

    $script:SDRequestHistory.Enqueue($now)
}
