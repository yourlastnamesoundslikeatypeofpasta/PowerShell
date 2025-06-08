function Export-MaintenancePlan {
    <#
    .SYNOPSIS
        Export a maintenance plan to JSON.
    .PARAMETER Plan
        Plan object created by New-MaintenancePlan.
    .PARAMETER Path
        Destination path for the JSON file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory,ValueFromPipeline)]
        [object]$Plan,
        [Parameter(Mandatory)][string]$Path
    )
    process {
        $Plan | ConvertTo-Json -Depth 5 | Set-Content -Path $Path
        Write-STStatus "Plan exported to $Path" -Level SUCCESS -Log
    }
}
