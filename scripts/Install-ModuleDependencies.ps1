<#
.SYNOPSIS
    Checks and installs required PowerShell modules.
.DESCRIPTION
    Verifies that common dependencies used by the modules in this repository are installed.
    Prompts to install from the PowerShell Gallery when a module is missing.
#>

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue

$requiredModules = @{ 
    'PnP.PowerShell' = 'SharePoint cleanup functions';
    'ExchangeOnlineManagement' = 'mailbox automation commands';
    'MicrosoftPlaces' = 'Invoke-CompanyPlaceManagement';
}

foreach ($name in $requiredModules.Keys) {
    if (-not (Get-Module -ListAvailable -Name $name)) {
        Write-STStatus "Module '$name' not found. Required for $($requiredModules[$name])." -Level WARN
        $install = Read-Host "Install $name from PSGallery? (Y/N)"
        if ($install -match '^[Yy]') {
            try {
                Install-Module -Name $name -Scope CurrentUser -Force -ErrorAction Stop
                Write-STStatus "Installed $name" -Level SUCCESS
            } catch {
                Write-STStatus "Failed to install $name: $($_.Exception.Message)" -Level ERROR
            }
        } else {
            Write-STStatus "$name was not installed. Some commands may not work." -Level WARN
        }
    } else {
        Write-STStatus "Module '$name' already installed." -Level SUCCESS
    }
}
