$PublicDir = Join-Path $PSScriptRoot 'Public'
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
$telemetryModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $coreModule -Force -ErrorAction SilentlyContinue -DisableNameChecking
Import-Module $loggingModule -Force -ErrorAction SilentlyContinue -DisableNameChecking
Import-Module $telemetryModule -Force -ErrorAction SilentlyContinue -DisableNameChecking

Get-ChildItem -Path "$PublicDir" -Filter *.ps1 -ErrorAction SilentlyContinue |
    ForEach-Object { . $_.FullName }

Export-ModuleMember -Function (
    Get-ChildItem "$PublicDir/*.ps1" -ErrorAction SilentlyContinue
).BaseName
