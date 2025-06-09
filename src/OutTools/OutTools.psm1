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
        [Parameter(Mandatory)][pscustomobject]$Info,
        [ValidateSet('Black','DarkBlue','DarkGreen','DarkCyan','DarkRed','DarkMagenta','DarkYellow','Gray','DarkGray','Blue','Green','Cyan','Red','Magenta','Yellow','White')]
        [string]$Color
    )
    if (-not $Info.Module) { throw 'Module property required' }
    $title = "$($Info.Module.ToUpper()) MODULE LOADED"
    if ($PSBoundParameters.ContainsKey('Color')) {
        $ansiMap = @{
            Black='30'; DarkBlue='34'; DarkGreen='32'; DarkCyan='36'; DarkRed='31';
            DarkMagenta='35'; DarkYellow='33'; Gray='37'; DarkGray='90'; Blue='94';
            Green='92'; Cyan='96'; Red='91'; Magenta='95'; Yellow='93'; White='97'
        }
        $code = $ansiMap[$Color]
        if ($code) { $title = "`e[${code}m$title`e[0m" }
    }
    Write-STDivider -Title $title -Style heavy
    Write-STStatus "Run 'Get-Command -Module $($Info.Module)' to view available tools." -Level SUB
    Write-STLog -Message "$($Info.Module) module loaded" -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
}

Export-ModuleMember -Function 'Out-STStatus','Out-STBanner'
