<#
.SYNOPSIS
    Launch an interactive menu to run common SupportTools tasks.
.DESCRIPTION
    Provides a simple CLI menu so colleagues can choose actions
    without typing commands. Each option invokes the related
    SupportTools function.
.EXAMPLE
    ./SupportToolsMenu.ps1
#>

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/SupportTools/SupportTools.psd1') -ErrorAction SilentlyContinue

param(
    [ValidateSet('Helpdesk','Site Admin')]
    [string]$UserRole = 'Helpdesk'
)

$Menu = @(
    @{ Label = 'Add users to group'; Action = { Write-STStatus -Message 'Running Add-UserToGroup...' -Level INFO; Add-UserToGroup } },
    @{ Label = 'Cleanup archive folder'; Action = { Write-STStatus -Message 'Running Clear-ArchiveFolder...' -Level INFO; Clear-ArchiveFolder } }
)

if ($UserRole -eq 'Helpdesk') {
    $Menu += @{ Label = 'Create ticket'; Action = {
            $subject = Read-Host 'Subject'
            $desc = Read-Host 'Description'
            $email = Read-Host 'Requester email'
            New-SDTicket -Subject $subject -Description $desc -RequesterEmail $email
        } }
}

if ($UserRole -eq 'Site Admin') {
    $Menu += @{ Label = 'Group membership cleanup'; Action = { Invoke-GroupMembershipCleanup } }
}

function Show-Menu {
    Write-STDivider -Title 'SupportTools Menu' -Style heavy
    for ($i = 0; $i -lt $Menu.Count; $i++) {
        $num = $i + 1
        Write-STStatus "$num. $($Menu[$i].Label)" -Level INFO
    }
    Write-STStatus -Message 'Q. Quit' -Level INFO
}

while ($true) {
    Show-Menu
    $choice = Read-Host 'Select an option'
    if ($choice -match '^[Qq]$') { break }
    $index = [int]$choice - 1
    if ($index -ge 0 -and $index -lt $Menu.Count) {
        & $Menu[$index].Action
    } else {
        Write-STStatus -Message 'Invalid choice. Try again.' -Level WARN
    }
    Write-STStatus -Message '' -Level INFO
}

Write-STClosing
