function Export-MaintenancePlan {
    <#
    .SYNOPSIS
        Export a maintenance plan to JSON.
    .PARAMETER Plan
        Plan object created by New-MaintenancePlan.
    .PARAMETER Path
        Destination path for the JSON file.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [ValidateNotNull()]
        [object]$Plan,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    process {
        if (-not $PSCmdlet.ShouldProcess($Path, 'Export maintenance plan')) { return }
        $Plan | ConvertTo-Json -Depth 5 | Set-Content -Path $Path
        Write-STStatus "Plan exported to $Path" -Level SUCCESS -Log
    }
}
