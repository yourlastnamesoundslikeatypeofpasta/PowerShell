function Wait-SDRateLimit {
    [CmdletBinding()]
    param(
        [int]$RateLimit
    )
    if (-not $RateLimit) { return }
    if (-not $script:SDRequestHistory) { $script:SDRequestHistory = @() }
    $now = Get-Date
    $script:SDRequestHistory = $script:SDRequestHistory | Where-Object { $_ -gt $now.AddMinutes(-1) }
    if ($script:SDRequestHistory.Count -ge $RateLimit) {
        $oldest = $script:SDRequestHistory[0]
        if ($oldest) {
            $wait = 60 - ($now - $oldest).TotalSeconds
            if ($wait -gt 0) {
                Write-Verbose "Rate limit reached, pausing for $wait seconds"
                Start-Sleep -Seconds [math]::Ceiling($wait)
            }
        }
    }
    $script:SDRequestHistory += $now
}
