function Invoke-SDRequest {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Method,
        [Parameter(Mandatory)][string]$Path,
        [hashtable]$Body
    )

    $baseUri = $env:SD_BASE_URI
    if (-not $baseUri) { $baseUri = 'https://api.samanage.com' }
    $token = $env:SD_API_TOKEN
    if (-not $token) { throw 'SD_API_TOKEN environment variable must be set.' }

    $headers = @{ 'X-Samanage-Authorization' = "Bearer $token"; Accept = 'application/json' }
    $uri = $baseUri.TrimEnd('/') + $Path
    Write-STLog "SDRequest $Method $uri"
    if ($Body) {
        $json = $Body | ConvertTo-Json -Depth 10
        try {
            Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body $json -ContentType 'application/json'
            Write-STLog "SUCCESS $Method $uri"
        } catch {
            Write-STLog "ERROR $Method $uri :: $_" -Level 'ERROR'
            throw
        }
    } else {
        try {
            Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
            Write-STLog "SUCCESS $Method $uri"
        } catch {
            Write-STLog "ERROR $Method $uri :: $_" -Level 'ERROR'
            throw
        }
    }
}
