$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $coreModule -Force -ErrorAction SilentlyContinue -DisableNameChecking
Import-Module $loggingModule -Force -ErrorAction SilentlyContinue -DisableNameChecking
Import-Module $telemetryModule -Force -ErrorAction SilentlyContinue -DisableNameChecking

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Get-CommonSystemInfo','Get-FailedLogin','Get-NetworkShare','Invoke-IncidentResponse','Invoke-RemoteAudit','Invoke-FullSystemAudit','New-SystemInfoTicket','Update-Sysmon','Search-Indicators'

function Show-IncidentResponseToolsBanner {
    [CmdletBinding()]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'IncidentResponseTools.psd1'
    [pscustomobject]@{
        Module  = 'IncidentResponseTools'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}
