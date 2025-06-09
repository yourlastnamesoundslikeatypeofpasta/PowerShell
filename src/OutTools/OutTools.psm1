function Out-STStatus {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Message,
        [Parameter()][ValidateSet('INFO','SUCCESS','ERROR','WARN','SUB','FINAL','FATAL')][string]$Level = 'INFO',
        [switch]$Log
    )
    Write-STStatus -Message $Message -Level $Level -Log:$Log
}

function Out-STBanner {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][pscustomobject]$Info
    )
    if (-not $Info.Module) { throw 'Module property required' }
    $title = "$($Info.Module.ToUpper()) MODULE LOADED"
    Write-STDivider $title -Style heavy
    Write-STStatus "Run 'Get-Command -Module $($Info.Module)' to view available tools." -Level SUB
    Write-STLog -Message "$($Info.Module) module loaded" -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
}

Export-ModuleMember -Function 'Out-STStatus','Out-STBanner'
