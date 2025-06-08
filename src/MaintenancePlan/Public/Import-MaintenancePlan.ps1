function Import-MaintenancePlan {
    <#
    .SYNOPSIS
        Import a maintenance plan from JSON.
    .PARAMETER Path
        Path to the JSON file.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path
    )
    Assert-ParameterNotNull $Path 'Path'
    if (-not (Test-Path $Path)) { throw "File not found: $Path" }
    Get-Content $Path -Raw | ConvertFrom-Json
}
