param()

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$settingsPath = Join-Path $repoRoot 'config/SharePointToolsSettings.psd1'

if (Test-Path $settingsPath) {
    try {
        $settings = Import-PowerShellDataFile $settingsPath
    } catch {
        $settings = @{ ClientId=''; TenantId=''; CertPath=''; Sites=@{} }
    }
} else {
    $settings = @{ ClientId=''; TenantId=''; CertPath=''; Sites=@{} }
}

if (-not $settings.ContainsKey('Sites')) { $settings.Sites = @{} }

Write-Host 'Enter SharePoint application settings. Leave blank to keep existing values.' -ForegroundColor Cyan
$clientId = Read-Host "Client ID (current: $($settings.ClientId))"
if ($clientId) { $settings.ClientId = $clientId }

$tenantId = Read-Host "Tenant ID (current: $($settings.TenantId))"
if ($tenantId) { $settings.TenantId = $tenantId }

$certPath = Read-Host "Certificate Path (current: $($settings.CertPath))"
if ($certPath) { $settings.CertPath = $certPath }

# Configure SharePoint sites
$currentSites = if ($settings.Sites.Count) { $settings.Sites.Keys -join ', ' } else { 'none' }
Write-Host "Current sites: $currentSites" -ForegroundColor Cyan
$siteInput = Read-Host 'Enter site pairs as Name=Url (comma separated) or leave blank to skip'
if ($siteInput) {
    foreach ($pair in ($siteInput -split ',')) {
        $parts = $pair -split '=',2
        if ($parts.Count -eq 2) {
            $name = $parts[0].Trim()
            $url  = $parts[1].Trim()
            if ($name -and $url) { $settings.Sites[$name] = $url }
        }
    }
}

$settings | Out-File -FilePath $settingsPath -Encoding utf8
Write-Host "Settings saved to $settingsPath" -ForegroundColor Green
