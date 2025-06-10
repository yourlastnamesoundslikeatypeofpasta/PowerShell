Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
$repoRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$defaultsFile = Join-Path $repoRoot 'config/config.psd1'
$STDefaults = Get-STConfig -Path $defaultsFile
$rootPath = Get-STConfigValue -Config $STDefaults -Key 'SystemDriveRoot'

param(
    [Parameter(Mandatory=$true)]
    [string]$IndicatorList
)

function Search-Indicators {
    [CmdletBinding()]
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

        try {
            $eventHits = Get-WinEvent -LogName Security,Application,System -ErrorAction SilentlyContinue |
                Where-Object { $_.Message -match [regex]::Escape($ind) }
        } catch {
            Write-STStatus "Event log search failed: $_" -Level ERROR
            $eventHits = @()
        }

        try {
            $regHits = Get-ChildItem -Path HKLM:\,HKCU:\ -Recurse -ErrorAction SilentlyContinue |
                Where-Object { $_.Name -match [regex]::Escape($ind) }
        } catch {
            Write-STStatus "Registry search failed: $_" -Level ERROR
            $regHits = @()
        }

        try {
            $fileHits = Get-ChildItem -Path $rootPath -Recurse -ErrorAction SilentlyContinue -Force |
                Where-Object { $_.FullName -match [regex]::Escape($ind) }
        } catch {
            Write-STStatus "Filesystem search failed: $_" -Level ERROR
            $fileHits = @()
        }
        [pscustomobject]@{
            Indicator      = $ind
            EventMatches   = $eventHits.Count
            RegistryMatches= $regHits.Count
            FileMatches    = $fileHits.Count
        }
    }
    Write-STStatus -Message 'Search complete.' -Level SUCCESS
    return $results
}

Search-Indicators -IndicatorList $IndicatorList
