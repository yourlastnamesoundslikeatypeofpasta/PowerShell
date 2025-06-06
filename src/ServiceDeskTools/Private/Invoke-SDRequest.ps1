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
    if ($Body) {
        $json = $Body | ConvertTo-Json -Depth 10
        Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers -Body $json -ContentType 'application/json'
    } else {
        Invoke-RestMethod -Method $Method -Uri $uri -Headers $headers
    }
}
