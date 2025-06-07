function Sync-SupportTools {
    <#
    .SYNOPSIS
        Synchronizes the SupportTools repository to the latest version.
    .DESCRIPTION
        Clones or pulls the specified Git repository and copies the modules
        to the user's PowerShell module directory.
    .PARAMETER RepoUrl
        URL of the Git repository containing SupportTools.
    .PARAMETER Destination
        Local path to clone the repository. Defaults to "$env:LOCALAPPDATA\SupportTools".
    .EXAMPLE
        Sync-SupportTools -RepoUrl "https://github.com/YOUR_ORG/PowerShell"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$RepoUrl,
        [string]$Destination = (Join-Path $env:LOCALAPPDATA 'SupportTools')
    )

    if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
        Write-STStatus 'Git is required to sync SupportTools.' -Level ERROR
        return
    }

    if (-not (Test-Path $Destination)) {
        Write-STStatus "Cloning repo to $Destination" -Level INFO
        git clone $RepoUrl $Destination | Out-Null
    }
    else {
        Write-STStatus 'Pulling latest changes' -Level INFO
        Push-Location $Destination
        try {
            git pull | Out-Null
        }
        finally {
            Pop-Location
        }
    }

    $source = Join-Path $Destination 'src'
    $target = Join-Path $HOME 'Documents/PowerShell/Modules'
    Write-STStatus 'Updating local modules' -Level INFO
    Copy-Item -Path (Join-Path $source '*') -Destination $target -Recurse -Force
    Write-STStatus 'SupportTools synchronized' -Level SUCCESS
}
