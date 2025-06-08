$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
Import-Module $loggingModule -ErrorAction SilentlyContinue
Import-Module $telemetryModule -ErrorAction SilentlyContinue

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Get-CommonSystemInfo','Get-FailedLogin','Get-NetworkShare','Invoke-IncidentResponse','Invoke-RemoteAudit','Invoke-FullSystemAudit','Submit-SystemInfoTicket','Update-Sysmon'

function Show-IncidentResponseToolsBanner {
    Write-STDivider 'INCIDENTRESPONSETOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module IncidentResponseTools' to view available tools." -Level SUB
    Write-STLog -Message 'IncidentResponseTools module loaded'
}

Show-IncidentResponseToolsBanner
