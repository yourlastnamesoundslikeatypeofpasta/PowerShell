function Invoke-SDRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [hashtable]$Body,
        [switch]$ChaosMode
    )

    $baseUri = $env:SD_BASE_URI
    if (-not $baseUri) { $baseUri = 'https://api.samanage.com' }
    $token = $env:SD_API_TOKEN
    if (-not $token) { throw 'SD_API_TOKEN environment variable must be set.' }

    if (-not $ChaosMode) { $ChaosMode = [bool]$env:ST_CHAOS_MODE }
    if ($ChaosMode) {
        $delay = Get-Random -Minimum 500 -Maximum 1500
        Write-STLog -Message "CHAOS MODE delay $delay ms"
        Start-Sleep -Milliseconds $delay
        $roll = Get-Random -Minimum 1 -Maximum 100
        if ($roll -le 10) { throw 'ChaosMode: simulated throttling (429 Too Many Requests)' }
        elseif ($roll -le 20) { throw 'ChaosMode: simulated server error (500 Internal Server Error)' }
    }

    $headers = @{ 'X-Samanage-Authorization' = "Bearer $token"; Accept = 'application/json' }
    $uri = $baseUri.TrimEnd('/') + $Path
    Write-STLog -Message "SDRequest $Method $uri"
    if ($Body) {
        $json = $Body | ConvertTo-Json -Depth 10
        try {
            Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body $json -ContentType 'application/json'
            Write-STLog -Message "SUCCESS $Method $uri"
        } catch {
            Write-STLog -Message "ERROR $Method $uri :: $_" -Level 'ERROR'
            throw
        }
    } else {
        try {
            Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
            Write-STLog -Message "SUCCESS $Method $uri"
        } catch {
            Write-STLog -Message "ERROR $Method $uri :: $_" -Level 'ERROR'
            throw
        }
    }
}
