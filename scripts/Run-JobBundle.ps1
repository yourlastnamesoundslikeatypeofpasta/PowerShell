<#+
.SYNOPSIS
    Executes a job packaged as a portable .job.zip bundle.
.DESCRIPTION
    The bundle is extracted to a temporary directory. job.json describes the
    script to run and optional arguments. Any modules found in the
    'dependencies' folder are added to $env:PSModulePath for the duration of the
    job. After the script runs the temporary directory is removed.
.PARAMETER BundlePath
    Path to the .job.zip file.
.EXAMPLE
    ./Run-JobBundle.ps1 -BundlePath ./AddUsersToGroup.job.zip
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$BundlePath
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
Import-Module (Join-Path $PSScriptRoot '..' 'src/Telemetry/Telemetry.psd1') -Force -ErrorAction SilentlyContinue

if (-not (Test-Path $BundlePath)) {
    throw "Bundle not found: $BundlePath"
}

Write-STStatus "Unpacking bundle $BundlePath" -Level INFO
$tempDir = Join-Path ([IO.Path]::GetTempPath()) ([guid]::NewGuid().ToString())
Expand-Archive -Path $BundlePath -DestinationPath $tempDir -Force

$jobFile = Join-Path $tempDir 'job.json'
if (-not (Test-Path $jobFile)) {
    throw 'job.json not found in bundle.'
}
$job = Get-Content $jobFile | ConvertFrom-Json

$scriptName = if ($job.Script) { $job.Script } else { 'job.ps1' }
$scriptPath = Join-Path $tempDir $scriptName
if (-not (Test-Path $scriptPath)) {
    throw "Job script not found: $scriptPath"
}

$depDir = Join-Path $tempDir 'dependencies'
if (Test-Path $depDir) {
    $env:PSModulePath = "$depDir$([IO.Path]::PathSeparator)$env:PSModulePath"
}

Push-Location $tempDir
$result = 'Success'
$start = Get-Date
try {
    if ($job.Parameters) {
        & $scriptPath @($job.Parameters)
    }
    else {
        & $scriptPath
    }
}
catch {
    Write-STLog -Message "Job bundle execution failed: $_" -Level 'ERROR'
    $result = 'Failure'
    throw
}
finally {
    $duration = (Get-Date) - $start
    Write-STTelemetryEvent -ScriptName (Split-Path $scriptPath -Leaf) -Result $result -Duration $duration
    Pop-Location
    Remove-Item $tempDir -Recurse -Force
}

