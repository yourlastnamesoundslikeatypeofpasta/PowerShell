$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
# SharePoint cleanup helpers

# Load configuration values if available
$repoRoot = Split-Path -Path $PSScriptRoot -Parent | Split-Path -Parent
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
$settingsFile = Join-Path $repoRoot 'config/SharePointToolsSettings.psd1'
$SharePointToolsSettings = @{ ClientId=''; TenantId=''; CertPath=''; Sites=@{} }
if (Test-Path $settingsFile) {
    try { $SharePointToolsSettings = Import-PowerShellDataFile $settingsFile } catch {}
}

$loggingModule = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Logging/Logging.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue
$telemetryModule = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $telemetryModule -ErrorAction SilentlyContinue

# Override configuration with environment variables when provided
if ($env:SPTOOLS_CLIENT_ID) { $SharePointToolsSettings.ClientId = $env:SPTOOLS_CLIENT_ID }
if ($env:SPTOOLS_TENANT_ID) { $SharePointToolsSettings.TenantId = $env:SPTOOLS_TENANT_ID }
if ($env:SPTOOLS_CERT_PATH) { $SharePointToolsSettings.CertPath = $env:SPTOOLS_CERT_PATH }

# Load required module once at module scope
try {
    Import-Module PnP.PowerShell -ErrorAction Stop
} catch {
    Write-STStatus 'PnP.PowerShell module not found. SharePoint functions may not work until it is installed.' -Level WARN
}

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir" -Filter *.ps1 -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }
Export-ModuleMember -Function @(
    'Invoke-YFArchiveCleanup',
    'Invoke-IBCCentralFilesArchiveCleanup',
    'Invoke-MexCentralFilesArchiveCleanup',
    'Invoke-ArchiveCleanup',
    'Invoke-YFFileVersionCleanup',
    'Invoke-IBCCentralFilesFileVersionCleanup',
    'Invoke-MexCentralFilesFileVersionCleanup',
    'Invoke-FileVersionCleanup',
    'Invoke-SharingLinkCleanup',
    'Invoke-YFSharingLinkCleanup',
    'Invoke-IBCCentralFilesSharingLinkCleanup',
    'Invoke-MexCentralFilesSharingLinkCleanup',
    'Get-SPToolsSettings',
    'Get-SPToolsSiteUrl',
    'Add-SPToolsSite',
    'Set-SPToolsSite',
    'Remove-SPToolsSite',
    'Get-SPToolsLibraryReport',
    'Get-SPToolsAllLibraryReports',
    'Get-SPToolsRecycleBinReport',
    'Clear-SPToolsRecycleBin',
    'Get-SPToolsAllRecycleBinReports',
    'Get-SPToolsFileReport',
    'Get-SPToolsPreservationHoldReport',
    'Get-SPToolsAllPreservationHoldReports',
    'Get-SPPermissionsReport',
    'Clean-SPVersionHistory',
    'Find-OrphanedSPFiles',
    'Select-SPToolsFolder',
    'List-OneDriveUsage',
    'Test-SPToolsPrereqs'
) -Variable 'SharePointToolsSettings'

Register-SPToolsCompleters
Show-SharePointToolsBanner
