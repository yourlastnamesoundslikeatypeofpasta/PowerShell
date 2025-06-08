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

Export-ModuleMember -Function 'Add-UserToGroup','Invoke-GroupMembershipCleanup','Install-Font','Install-MaintenanceTasks','Invoke-CompanyPlaceManagement','Invoke-DeploymentTemplate','Invoke-ExchangeCalendarManager','Invoke-PostInstall','Set-ComputerIPAddress','Set-NetAdapterMetering','Set-SharedMailboxAutoReply','Set-TimeZoneEasternStandardTime','Test-Drift'

function Show-ConfigManagementToolsBanner {
    [CmdletBinding()]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'ConfigManagementTools.psd1'
    [pscustomobject]@{
        Module  = 'ConfigManagementTools'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}
