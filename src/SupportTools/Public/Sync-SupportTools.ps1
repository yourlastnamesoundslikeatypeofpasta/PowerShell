function Sync-SupportTools {
    <#
    .SYNOPSIS
        Updates the SupportTools modules from a git repository.
    .DESCRIPTION
        Clones the repository if it does not exist locally, otherwise pulls the latest changes.
        The module manifests under the `src` folder are imported after synchronization.
    .PARAMETER RepositoryUrl
        URL of the git repository to sync.
    .PARAMETER InstallPath
        Directory to clone or update the repository.
    #>
    [CmdletBinding()]
    param(
        [string]$RepositoryUrl = 'https://github.com/yourlastnamesoundslikeatypeofpasta/PowerShell.git',
        [string]$InstallPath = $(if ($env:USERPROFILE) { Join-Path $env:USERPROFILE 'SupportTools' } else { Join-Path $env:HOME 'SupportTools' }),
        [switch]$Explain
    )

    if ($Explain) {
        Get-Help $MyInvocation.PSCommandPath -Full
        return
    }

    Invoke-STSafe -OperationName 'Sync-SupportTools' -ScriptBlock {
        if (Test-Path (Join-Path $InstallPath '.git')) {
            git -C $InstallPath pull
        }
        else {
            git clone $RepositoryUrl $InstallPath
        }

        Import-Module (Join-Path $InstallPath 'src/SupportTools/SupportTools.psd1') -Force
        $sp = Join-Path $InstallPath 'src/SharePointTools/SharePointTools.psd1'
        if (Test-Path $sp) { Import-Module $sp -ErrorAction SilentlyContinue }
        $sd = Join-Path $InstallPath 'src/ServiceDeskTools/ServiceDeskTools.psd1'
        if (Test-Path $sd) { Import-Module $sd -ErrorAction SilentlyContinue }

        Write-STStatus 'SupportTools synchronized' -Level FINAL
    }
}
