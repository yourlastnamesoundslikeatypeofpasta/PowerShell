function Invoke-SDRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [hashtable]$Body,
        [switch]$ChaosMode
    )
    Assert-ParameterNotNull $Method 'Method'
    Assert-ParameterNotNull $Path 'Path'

    $baseUri = $env:SD_BASE_URI
    if (-not $baseUri) { $baseUri = 'https://api.samanage.com' }
    $token = $env:SD_API_TOKEN
    if (-not $token) { throw 'SD_API_TOKEN environment variable must be set.' }

    if (-not $ChaosMode) { $ChaosMode = [bool]$env:ST_CHAOS_MODE }
    if ($ChaosMode) {
        $delay = Get-Random -Minimum 500 -Maximum 1500
        Write-STLog -Message "CHAOS MODE delay $delay ms" -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
        Start-Sleep -Milliseconds $delay
        $roll = Get-Random -Minimum 1 -Maximum 100
        if ($roll -le 10) { throw 'ChaosMode: simulated throttling (429 Too Many Requests)' }
        elseif ($roll -le 20) { throw 'ChaosMode: simulated server error (500 Internal Server Error)' }
    }

    $rateLimit = if ($env:SD_RATE_LIMIT_PER_MINUTE) { [int]$env:SD_RATE_LIMIT_PER_MINUTE } else { $null }
    if ($rateLimit) {
        if (-not $script:SDRequestHistory) { $script:SDRequestHistory = @() }
        $now = Get-Date
        $script:SDRequestHistory = $script:SDRequestHistory | Where-Object { $_ -gt $now.AddMinutes(-1) }
        if ($script:SDRequestHistory.Count -ge $rateLimit) {
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

    $headers = @{ 'X-Samanage-Authorization' = "Bearer $token"; Accept = 'application/json' }
    $uri = $baseUri.TrimEnd('/') + $Path
    Write-STLog -Message "SDRequest $Method $uri" -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
    Write-Verbose "Invoking $Method $uri"
    $json = if ($Body) { $Body | ConvertTo-Json -Depth 10 } else { $null }
    $maxRetries = 3
    $attempt = 1
    while ($true) {
        try {
            if ($json) {
                $response = Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body $json -ContentType 'application/json'
            } else {
                $response = Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
            }
            Write-STLog -Message "SUCCESS $Method $uri" -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
            return $response
        } catch [System.Net.WebException],[Microsoft.PowerShell.Commands.HttpResponseException] {
            $status = $_.Exception.Response.StatusCode.value__
            $msg    = $_.Exception.Message
            Write-STLog -Message "HTTP $status $msg" -Level 'ERROR' -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
            if ($status -eq 429 -or ($status -ge 500 -and $status -lt 600)) {
                if ($attempt -lt $maxRetries) {
                    $retryAfter = $_.Exception.Response.Headers['Retry-After']
                    if ($retryAfter) {
                        $delay = [int]$retryAfter
                    } else {
                        $delay = [math]::Pow(2, $attempt)
                    }
                    Write-STLog -Message "Retry $attempt in $delay sec" -Level WARN -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
                    Write-Verbose "Retrying in $delay seconds"
                    Start-Sleep -Seconds $delay
                    $attempt++
                    continue
                }
            }
            $errorObj = New-STErrorObject -Message "HTTP $status $msg" -Category 'HTTP'
            throw $errorObj
        } catch {
            Write-STLog -Message "ERROR $Method $uri :: $_" -Level 'ERROR' -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
            throw
        }
    }
}
