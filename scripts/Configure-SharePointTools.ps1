param()

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$settingsPath = Join-Path $repoRoot 'config/SharePointToolsSettings.psd1'

if (Test-Path $settingsPath) {
    try {
        $settings = Import-PowerShellDataFile $settingsPath
    } catch {
        $settings = @{ ClientId=''; TenantId=''; CertPath='' }
    }
} else {
    $settings = @{ ClientId=''; TenantId=''; CertPath='' }
}

Write-Host 'Enter SharePoint application settings. Leave blank to keep existing values.' -ForegroundColor Cyan
$clientId = Read-Host "Client ID (current: $($settings.ClientId))"
if ($clientId) { $settings.ClientId = $clientId }

$tenantId = Read-Host "Tenant ID (current: $($settings.TenantId))"
if ($tenantId) { $settings.TenantId = $tenantId }

$certPath = Read-Host "Certificate Path (current: $($settings.CertPath))"
if ($certPath) { $settings.CertPath = $certPath }

$settings | Out-File -FilePath $settingsPath -Encoding utf8
Write-Host "Settings saved to $settingsPath" -ForegroundColor Green
