$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
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

# Alias mappings
Set-Alias -Name 'NewHire-Automation' -Value 'Invoke-NewHireUserAutomation'


Export-ModuleMember -Function @(
    'Clear-ArchiveFolder',
    'Clear-TempFile',
    'Convert-ExcelToCsv',
    'Export-ProductKey',
    'New-SPUsageReport',
    'Get-UniquePermission',
    'Invoke-JobBundle',
    'Invoke-PerformanceAudit',
    'Restore-ArchiveFolder',
    'Search-ReadMe',
    'Start-Countdown',
    'Export-ITReport',
    'New-STDashboard',
    'Sync-SupportTools',
    'Invoke-NewHireUserAutomation'
) -Alias 'NewHire-Automation'


function Show-SupportToolsBanner {
    <#
    .SYNOPSIS
        Returns SupportTools module metadata for banner display.
    #>
    [CmdletBinding()]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'SupportTools.psd1'
    [pscustomobject]@{
        Module  = 'SupportTools'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}
