function Import-MaintenancePlan {
    <#
    .SYNOPSIS
        Import a maintenance plan from JSON.
    .PARAMETER Path
        Path to the JSON file.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$Path
    )
    Assert-ParameterNotNull $Path 'Path'
    if (-not (Test-Path $Path)) { throw "File not found: $Path" }
    Get-Content $Path -Raw | ConvertFrom-Json
}
