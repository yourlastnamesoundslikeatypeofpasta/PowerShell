$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue
Import-Module $telemetryModule -ErrorAction SilentlyContinue

# Determine the version of the SupportTools module for logging purposes
$manifestPath = Join-Path $PSScriptRoot 'SupportTools.psd1'
$STModuleVersion = try {
    (Import-PowerShellDataFile $manifestPath).ModuleVersion
} catch {
    'unknown'
}

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir" -Filter *.ps1 -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }


Export-ModuleMember -Function (
    Get-ChildItem "$PublicDir/*.ps1" -ErrorAction SilentlyContinue
).BaseName


function Show-SupportToolsBanner {
    Write-STStatus '════════════════════════════════════════════' -Level INFO
    Write-STStatus 'SUPPORTTOOLS MODULE ACTIVATED' -Level SUCCESS
    Write-STStatus '════════════════════════════════════════════' -Level INFO
    Write-STStatus "Run 'Get-Command -Module SupportTools' to view available tools." -Level SUB
    Write-STLog 'SupportTools module loaded'
}

Show-SupportToolsBanner
