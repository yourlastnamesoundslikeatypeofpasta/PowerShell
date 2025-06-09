param(
    [string]$ClientId,
    [string]$TenantId,
    [string]$CertPath,
    [hashtable]$Sites
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/STCore/STCore.psd1') -ErrorAction SilentlyContinue

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$settingsPath = Join-Path $repoRoot 'config/SharePointToolsSettings.psd1'

$settings = Get-STConfig -Path $settingsPath
if (-not $settings) { $settings = @{} }
if (-not $settings.ContainsKey('ClientId')) { $settings.ClientId = '' }
if (-not $settings.ContainsKey('TenantId')) { $settings.TenantId = '' }
if (-not $settings.ContainsKey('CertPath')) { $settings.CertPath = '' }
if (-not $settings.ContainsKey('Sites')) { $settings.Sites = @{} }

if (-not $settings.ContainsKey('Sites')) { $settings.Sites = @{} }

if ($PSBoundParameters.ContainsKey('ClientId')) {
    $settings.ClientId = $ClientId
} else {
    Write-STStatus -Message 'Enter SharePoint application settings. Leave blank to keep existing values.' -Level INFO
    $clientId = Read-Host "Client ID (current: $($settings.ClientId))"
    if ($clientId) { $settings.ClientId = $clientId }
}

if ($PSBoundParameters.ContainsKey('TenantId')) {
    $settings.TenantId = $TenantId
} else {
    $tenantId = Read-Host "Tenant ID (current: $($settings.TenantId))"
    if ($tenantId) { $settings.TenantId = $tenantId }
}

if ($PSBoundParameters.ContainsKey('CertPath')) {
    $settings.CertPath = $CertPath
} else {
    $certPath = Read-Host "Certificate Path (current: $($settings.CertPath))"
    if ($certPath) { $settings.CertPath = $certPath }
}

# Configure SharePoint sites
if ($PSBoundParameters.ContainsKey('Sites')) {
    foreach ($key in $Sites.Keys) { $settings.Sites[$key] = $Sites[$key] }
} else {
    $currentSites = if ($settings.Sites.Count) { $settings.Sites.Keys -join ', ' } else { 'none' }
    Write-STStatus "Current sites: $currentSites" -Level INFO
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
}

$settings | Out-File -FilePath $settingsPath -Encoding utf8
Write-STStatus "Settings saved to $settingsPath" -Level SUCCESS

$banner = @'
          .-"""-.
         / .===. \
         \/ 6 6 \/
         ( \___/ )
___ooo____\_____/_______ooo___
 _       __________    __________  __  _________
| |     / / ____/ /   / ____/ __ \/  |/  / ____/
| | /| / / __/ / /   / /   / / / / /|_/ / __/   
| |/ |/ / /___/ /___/ /___/ /_/ / /  / / /___   
|__/|__/_____/_____/\____/\____/_/  /_/_____/   

 ___ _                 ___     _     _     _____         _
/ __| |_  __ _ _ _ ___| _ \___(_)_ _| |_  |_   _|__  ___| |___
\__ \ ' \/ _` | '_/ -_)  _/ _ \ | ' \  _|   | |/ _ \/ _ \ (_-<
|___/_||_\__,_|_| \___|_| \___/_|_||_\__|   |_|\___/\___/_/__/
'@

Write-STStatus $banner -Level SUCCESS
