Param(
    [string]$Version
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $MyInvocation.MyCommand.Path
. (Join-Path $root 'SupportToolsLoader.ps1')
if (-not $Version) {
    $Version = (Import-PowerShellDataFile (Join-Path $root 'src/SupportTools/SupportTools.psd1')).ModuleVersion
}
$packageDir = Join-Path $root 'artifacts'
if (Test-Path $packageDir) { Remove-Item $packageDir -Recurse -Force }
New-Item $packageDir -ItemType Directory | Out-Null
Copy-Item -Path (Join-Path $root 'src') -Destination $packageDir -Recurse
Copy-Item -Path (Join-Path $root 'tests') -Destination $packageDir -Recurse

$nuget = (Get-Command nuget -ErrorAction SilentlyContinue).Source
if (-not $nuget) {
    $nuget = Join-Path $packageDir 'nuget.exe'
    if (-not (Test-Path $nuget)) {
        Invoke-WebRequest 'https://dist.nuget.org/win-x86-commandline/latest/nuget.exe' -OutFile $nuget
    }
}
& $nuget pack (Join-Path $root 'SupportTools.nuspec') -Version $Version -OutputDirectory $packageDir
Write-STLog -Message "Package created in $packageDir" -Level INFO

