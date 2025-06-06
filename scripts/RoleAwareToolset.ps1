<#+
.SYNOPSIS
    Launch an interactive toolset with role-based options.
.DESCRIPTION
    Displays a simple menu exposing different functionality depending on the supplied
    -UserRole parameter. "Helpdesk" users can create a Service Desk ticket while
    "Site Admin" users can run group membership cleanup.
.PARAMETER UserRole
    Role of the current user. Accepts 'Helpdesk' or 'Site Admin'. Defaults to 'Helpdesk'.
#>
param(
    [ValidateSet('Helpdesk','Site Admin')]
    [string]$UserRole = 'Helpdesk'
)

Import-Module (Join-Path $PSScriptRoot '..' 'src' 'SupportTools' 'SupportTools.psd1') -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src' 'ServiceDeskTools' 'ServiceDeskTools.psd1') -ErrorAction SilentlyContinue

while ($true) {
    Write-STDivider 'ROLE AWARE TOOLSET'
    if ($UserRole -eq 'Helpdesk') {
        Write-STStatus '1 - Create Ticket' -Level INFO
    }
    if ($UserRole -eq 'Site Admin') {
        Write-STStatus '1 - Group Membership Cleanup' -Level INFO
    }
    Write-STStatus 'Q - Quit' -Level INFO
    $choice = Read-Host 'Select an option'
    if ($choice -match '^[Qq]$') { break }
    switch ($choice) {
        '1' {
            if ($UserRole -eq 'Helpdesk') {
                $subject = Read-Host 'Ticket subject'
                $desc = Read-Host 'Ticket description'
                $email = Read-Host 'Requester email'
                New-SDTicket -Subject $subject -Description $desc -RequesterEmail $email | Out-Null
            } elseif ($UserRole -eq 'Site Admin') {
                $group = Read-Host 'Group name'
                Invoke-GroupMembershipCleanup -Arguments @('-GroupName', $group)
            }
        }
        default { Write-STStatus 'Invalid selection.' -Level ERROR }
    }
}
