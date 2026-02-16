[CmdletBinding()]
param(
    [string]$ProjectPath,
    [string]$PythonCommand,
    [string]$VenvName,
    [string]$RequirementsFile,
    [ValidateSet('script', 'module', 'custom')]
    [string]$ServerLaunchMode,
    [string]$ServerTarget,
    [string[]]$ServerArguments,
    [switch]$SkipPrompts,
    [switch]$PrepareOnly
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

function Read-OnboardingValue {
    param(
        [Parameter(Mandatory)]
        [string]$Prompt,
        [Parameter(Mandatory)]
        [string]$Default,
        [switch]$Required
    )

    $value = Read-Host "$Prompt [$Default]"
    if ([string]::IsNullOrWhiteSpace($value)) {
        $value = $Default
    }

    if ($Required -and [string]::IsNullOrWhiteSpace($value)) {
        throw "A value is required for '$Prompt'."
    }

    return $value.Trim()
}

function Resolve-PythonCommand {
    param([string]$RequestedCommand)

    if (-not [string]::IsNullOrWhiteSpace($RequestedCommand)) {
        return $RequestedCommand
    }

    foreach ($candidate in @('python', 'python3', 'py')) {
        if (Get-Command -Name $candidate -ErrorAction SilentlyContinue) {
            return $candidate
        }
    }

    throw 'Python was not found on PATH. Install Python 3.9+ and run this script again.'
}

Write-Host '--- Python onboarding ---' -ForegroundColor Cyan

if (-not $SkipPrompts) {
    if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
        $ProjectPath = Read-OnboardingValue -Prompt 'Project directory' -Default (Get-Location).Path -Required
    }

    if ([string]::IsNullOrWhiteSpace($PythonCommand)) {
        $PythonCommand = Read-OnboardingValue -Prompt 'Python command' -Default 'python'
    }

    if ([string]::IsNullOrWhiteSpace($VenvName)) {
        $VenvName = Read-OnboardingValue -Prompt 'Virtual environment folder' -Default '.venv'
    }

    if ([string]::IsNullOrWhiteSpace($RequirementsFile)) {
        $RequirementsFile = Read-OnboardingValue -Prompt 'Requirements file path (relative to project)' -Default 'requirements.txt'
    }

    if ([string]::IsNullOrWhiteSpace($ServerLaunchMode)) {
        $ServerLaunchMode = Read-OnboardingValue -Prompt 'Server launch mode (script, module, custom)' -Default 'script'
    }

    if ([string]::IsNullOrWhiteSpace($ServerTarget)) {
        $defaultTarget = if ($ServerLaunchMode -eq 'module') { 'uvicorn' } elseif ($ServerLaunchMode -eq 'custom') { 'python app.py' } else { 'app.py' }
        $ServerTarget = Read-OnboardingValue -Prompt 'Server target' -Default $defaultTarget -Required
    }

    if (-not $ServerArguments -or $ServerArguments.Count -eq 0) {
        $serverArgsRaw = Read-OnboardingValue -Prompt 'Server arguments (space separated)' -Default ''
        if (-not [string]::IsNullOrWhiteSpace($serverArgsRaw)) {
            $ServerArguments = $serverArgsRaw -split '\s+'
        }
    }
}

if ([string]::IsNullOrWhiteSpace($ProjectPath)) {
    $ProjectPath = (Get-Location).Path
}

if ([string]::IsNullOrWhiteSpace($VenvName)) {
    $VenvName = '.venv'
}

if ([string]::IsNullOrWhiteSpace($RequirementsFile)) {
    $RequirementsFile = 'requirements.txt'
}

if ([string]::IsNullOrWhiteSpace($ServerLaunchMode)) {
    $ServerLaunchMode = 'script'
}

if ([string]::IsNullOrWhiteSpace($ServerTarget)) {
    $ServerTarget = if ($ServerLaunchMode -eq 'module') { 'uvicorn' } elseif ($ServerLaunchMode -eq 'custom') { 'python app.py' } else { 'app.py' }
}

$ProjectPath = [System.IO.Path]::GetFullPath($ProjectPath)
if (-not (Test-Path -Path $ProjectPath -PathType Container)) {
    throw "Project directory '$ProjectPath' does not exist."
}

$PythonCommand = Resolve-PythonCommand -RequestedCommand $PythonCommand
$venvPath = Join-Path $ProjectPath $VenvName
$requirementsPath = Join-Path $ProjectPath $RequirementsFile

if (-not (Test-Path -Path $requirementsPath -PathType Leaf)) {
    throw "Requirements file '$requirementsPath' was not found."
}

Write-Host "Using project path: $ProjectPath" -ForegroundColor DarkCyan
Write-Host "Using python command: $PythonCommand" -ForegroundColor DarkCyan
Write-Host "Using venv path: $venvPath" -ForegroundColor DarkCyan
Write-Host "Using requirements file: $requirementsPath" -ForegroundColor DarkCyan

if (-not (Test-Path -Path $venvPath -PathType Container)) {
    Write-Host 'Creating virtual environment...' -ForegroundColor Yellow
    Push-Location $ProjectPath
    try {
        & $PythonCommand -m venv $VenvName
    }
    finally {
        Pop-Location
    }
}
else {
    Write-Host 'Virtual environment already exists. Reusing it.' -ForegroundColor Yellow
}

$venvPython = Join-Path $venvPath (if ($IsWindows) { 'Scripts/python.exe' } else { 'bin/python' })
if (-not (Test-Path -Path $venvPython -PathType Leaf)) {
    throw "Unable to find virtual environment python executable at '$venvPython'."
}

Write-Host 'Installing dependencies...' -ForegroundColor Yellow
& $venvPython -m pip install --upgrade pip
& $venvPython -m pip install -r $requirementsPath

if ($PrepareOnly) {
    $activateHint = if ($IsWindows) { Join-Path $venvPath 'Scripts/Activate.ps1' } else { Join-Path $venvPath 'bin/activate' }
    Write-Host 'Environment is ready. Skipping server start because -PrepareOnly was provided.' -ForegroundColor Green
    Write-Host "Activation command: $activateHint" -ForegroundColor DarkCyan
    return
}

Write-Host 'Starting server...' -ForegroundColor Green
Push-Location $ProjectPath
try {
    switch ($ServerLaunchMode) {
        'script' {
            & $venvPython $ServerTarget @ServerArguments
        }
        'module' {
            & $venvPython -m $ServerTarget @ServerArguments
        }
        'custom' {
            $customExecutable = $ServerTarget
            if ($customExecutable -in @('python', 'python3', 'py')) {
                $customExecutable = $venvPython
            }

            Write-Host "Executing custom command: $customExecutable $($ServerArguments -join ' ')" -ForegroundColor DarkCyan
            & $customExecutable @ServerArguments
        }
    }
}
finally {
    Pop-Location
}
