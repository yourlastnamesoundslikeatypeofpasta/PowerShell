$publicDir = Join-Path $PSScriptRoot 'Public'
$privateDir = Join-Path $PSScriptRoot 'Private'

Get-ChildItem -Path "$privateDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$publicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Add-UsersToGroup','Clear-ArchiveFolder','Convert-ExcelToCsv','Get-CommonSystemInfo','Get-FailedLogins','Get-NetworkShares','Get-UniquePermissions','Install-Fonts','Invoke-PostInstall','Export-ProductKey','Invoke-DeploymentTemplate','Search-ReadMe','Set-ComputerIPAddress','Set-NetAdapterMetering','Set-TimeZoneEasternStandardTime','Start-Countdown','Update-Sysmon','Set-SharedMailboxAutoReply','Invoke-ExchangeCalendarManager','Invoke-CompanyPlaceManagement'
