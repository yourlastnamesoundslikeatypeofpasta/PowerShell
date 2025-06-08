$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue

function New-MaintenancePlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Name,
        [Parameter(Mandatory)][string[]]$Tasks,
        [string]$Schedule = '0 3 * * Sun'
    )
    Assert-ParameterNotNull $Name 'Name'
    Assert-ParameterNotNull $Tasks 'Tasks'
    [pscustomobject]@{
        Name     = $Name
        Tasks    = $Tasks
        Schedule = $Schedule
    }
}

function Export-MaintenancePlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Plan,
        [Parameter(Mandatory)][string]$Path
    )
    Assert-ParameterNotNull $Plan 'Plan'
    Assert-ParameterNotNull $Path 'Path'
    $json = $Plan | ConvertTo-Json -Depth 5
    $dir = Split-Path -Path $Path -Parent
    if ($dir -and -not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    Set-Content -Path $Path -Value $json -Encoding UTF8
}

function Import-MaintenancePlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Path
    )
    Assert-ParameterNotNull $Path 'Path'
    if (-not (Test-Path $Path)) { throw "Plan file not found: $Path" }
    Get-Content -Path $Path -Raw | ConvertFrom-Json
}

function Invoke-MaintenancePlan {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]$Plan
    )
    foreach ($task in $Plan.Tasks) {
        if (Test-Path $task) {
            Write-STStatus "Running script $task" -Level INFO -Log
            & $task
        } elseif (Get-Command $task -ErrorAction SilentlyContinue) {
            Write-STStatus "Invoking command $task" -Level INFO -Log
            & $task
        } else {
            Write-STStatus "Task $task not found" -Level ERROR -Log
        }
    }
}

Export-ModuleMember -Function 'New-MaintenancePlan','Export-MaintenancePlan','Import-MaintenancePlan','Invoke-MaintenancePlan'

function Show-MaintenancePlanBanner {
    [CmdletBinding()]
    param()
    Write-STDivider 'MAINTENANCEPLAN MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module MaintenancePlan' to view available tools." -Level SUB
    Write-STLog -Message 'MaintenancePlan module loaded'
}

Show-MaintenancePlanBanner
