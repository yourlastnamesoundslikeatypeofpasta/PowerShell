Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue

param(
    [Parameter(Mandatory=$true)]
    [string]$IndicatorList
)

function Search-Indicators {
    <#
    .SYNOPSIS
        Search event logs, registry and file system for suspicious indicators.
    .DESCRIPTION
        Reads a CSV file containing indicators and scans common forensic sources
        for occurrences. The CSV must contain an 'Indicator' column listing
        strings such as IPs, domains or hashes.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)][string]$IndicatorList
    )

    if (-not (Test-Path $IndicatorList)) { throw "Indicator list '$IndicatorList' not found." }
    Write-STStatus "Loading indicators from $IndicatorList" -Level INFO
    $indicators = Import-Csv -Path $IndicatorList | Select-Object -ExpandProperty Indicator
    $results = foreach ($ind in $indicators) {
        Write-STStatus "Searching for '$ind'" -Level SUB
        $eventHits = Get-WinEvent -LogName Security,Application,System -ErrorAction SilentlyContinue |
            Where-Object { $_.Message -match [regex]::Escape($ind) }
        $regHits = Get-ChildItem -Path HKLM:\,HKCU:\ -Recurse -ErrorAction SilentlyContinue |
            Where-Object { $_.Name -match [regex]::Escape($ind) }
        $fileHits = Get-ChildItem -Path C:\ -Recurse -ErrorAction SilentlyContinue -Force |
            Where-Object { $_.FullName -match [regex]::Escape($ind) }
        [pscustomobject]@{
            Indicator      = $ind
            EventMatches   = $eventHits.Count
            RegistryMatches= $regHits.Count
            FileMatches    = $fileHits.Count
        }
    }
    Write-STStatus 'Search complete.' -Level SUCCESS
    return $results
}

Search-Indicators -IndicatorList $IndicatorList
