<#
.SYNOPSIS
    Checks and installs required PowerShell modules.
.DESCRIPTION
    Verifies that common dependencies used by the modules in this repository are installed.
    Prompts to install from the PowerShell Gallery when a module is missing.
#>

$requiredModules = @{ 
    'PnP.PowerShell' = 'SharePoint cleanup functions';
    'ExchangeOnlineManagement' = 'mailbox automation commands';
    'MicrosoftPlaces' = 'Invoke-CompanyPlaceManagement';
}

foreach ($name in $requiredModules.Keys) {
    if (-not (Get-Module -ListAvailable -Name $name)) {
        Write-Warning "Module '$name' not found. Required for $($requiredModules[$name])."
        $install = Read-Host "Install $name from PSGallery? (Y/N)"
        if ($install -match '^[Yy]') {
            try {
                Install-Module -Name $name -Scope CurrentUser -Force -ErrorAction Stop
                Write-Host "Installed $name" -ForegroundColor Green
            } catch {
                Write-Warning "Failed to install $name: $($_.Exception.Message)"
            }
        } else {
            Write-Warning "$name was not installed. Some commands may not work."
        }
    } else {
        Write-Host "Module '$name' already installed." -ForegroundColor Green
    }
}
