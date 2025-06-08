function Test-SPToolsPrereqs {
    <#
    .SYNOPSIS
        Validates required modules for SharePoint tools.
    .DESCRIPTION
        Checks that the PnP.PowerShell module is available. Use -Install to
        automatically install it from the PowerShell Gallery when missing.
    .PARAMETER Install
        If specified, missing modules are installed without prompting.
    #>
    [CmdletBinding()]
    param(
        [switch]$Install
    )
    process {
        if (-not (Get-Module -ListAvailable -Name 'PnP.PowerShell')) {
            Write-SPToolsHacker 'PnP.PowerShell module not found.' -Level WARN
            if ($Install) {
                try {
                    Install-Module -Name 'PnP.PowerShell' -Scope CurrentUser -Force -ErrorAction Stop
                    Write-SPToolsHacker 'Installed PnP.PowerShell' -Level SUCCESS
                } catch {
                    Write-SPToolsHacker "Failed to install PnP.PowerShell: $($_.Exception.Message)" -Level ERROR
                }
            } else {
                Write-SPToolsHacker "Run 'Test-SPToolsPrereqs -Install' to install." -Level SUB
            }
        } else {
            Write-SPToolsHacker 'PnP.PowerShell module present.' -Level SUCCESS
        }
    }
}

