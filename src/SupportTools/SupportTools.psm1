$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Add-UsersToGroup','Clear-ArchiveFolder','Convert-ExcelToCsv','Get-CommonSystemInfo','Get-FailedLogins','Get-NetworkShares','Get-UniquePermissions','Install-Fonts','Invoke-PostInstall','Export-ProductKey','Invoke-DeploymentTemplate','Search-ReadMe','Set-ComputerIPAddress','Set-NetAdapterMetering','Set-TimeZoneEasternStandardTime','Start-Countdown','Update-Sysmon','Set-SharedMailboxAutoReply','Invoke-ExchangeCalendarManager','Invoke-CompanyPlaceManagement'

function Show-SupportToolsBanner {
    $lines = @(
        '=======================================',
        '=    SUPPORTTOOLS MODULE ACTIVATED    =',
        '=======================================')
    foreach ($line in $lines) {
        Write-Host $line -ForegroundColor Black -BackgroundColor Green
    }
    Write-Host '>> Welcome operator. Run ''Get-Command -Module SupportTools'' to view available tools.' -ForegroundColor Green -BackgroundColor Black
}

Show-SupportToolsBanner
