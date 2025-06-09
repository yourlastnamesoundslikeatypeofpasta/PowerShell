function Export-SDConfig {
    <#
    .SYNOPSIS
        Export Service Desk environment configuration to JSON.
    .DESCRIPTION
        Writes non-sensitive settings such as SD_BASE_URI, SD_ASSET_BASE_URI and
        SD_RATE_LIMIT_PER_MINUTE to the specified path. The API token is not
        included.
    .PARAMETER Path
        Destination path for the JSON file.
    .EXAMPLE
        Export-SDConfig -Path './sdconfig.json'
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )

    $config = @{}
    if ($env:SD_BASE_URI) { $config.BaseUri = $env:SD_BASE_URI }
    if ($env:SD_ASSET_BASE_URI) { $config.AssetBaseUri = $env:SD_ASSET_BASE_URI }
    if ($env:SD_RATE_LIMIT_PER_MINUTE) { $config.RateLimitPerMinute = [int]$env:SD_RATE_LIMIT_PER_MINUTE }

    if ($PSCmdlet.ShouldProcess($Path, 'Export config')) {
        $config | ConvertTo-Json -Depth 5 | Set-Content -Path $Path
        Write-STStatus "Config exported to $Path" -Level SUCCESS -Log
    }
}
