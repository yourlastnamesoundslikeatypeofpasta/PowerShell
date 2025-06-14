function Invoke-ScriptFile {
    <#
    .SYNOPSIS
        Executes a script from the repository's scripts folder.
    .PARAMETER Name
        Name of the script file to execute.
    .PARAMETER Args
        Additional arguments to pass to the script.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string]$Name,
        [Parameter(ValueFromRemainingArguments=$true)]
        [object[]]$Args,
        [object]$Logger,
        [object]$TelemetryClient,
        [object]$Config,
        [string]$TranscriptPath,
        [switch]$Simulate,
        [switch]$Explain
    )
    Assert-ParameterNotNull $Name 'Name'
    # Retrieve the SupportTools module version for log metadata
    $manifest = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'SupportTools.psd1'
    $moduleVersion = try {
        (Import-PowerShellDataFile $manifest).ModuleVersion
    } catch {
        'unknown'
    }

    if ($Logger) {
        Import-Module $Logger -Force -ErrorAction SilentlyContinue
    } elseif ($loggingModule) {
        Import-Module $loggingModule -Force -ErrorAction SilentlyContinue
    }

    if ($TelemetryClient) {
        Import-Module $TelemetryClient -Force -ErrorAction SilentlyContinue
    } elseif ($telemetryModule) {
        Import-Module $telemetryModule -Force -ErrorAction SilentlyContinue
    }

    if ($Config) {
        Import-Module $Config -Force -ErrorAction SilentlyContinue
    }
    $Path = Join-Path $PSScriptRoot '..' |
            Join-Path -ChildPath '..' |
            Join-Path -ChildPath '..' |
            Join-Path -ChildPath "scripts/$Name"
    if (-not (Test-Path $Path)) { throw "Script '$Name' not found." }

    if ($Explain) {
        Get-Help $Path -Full
        return
    }

    Write-STStatus "EXECUTING $Name" -Level SUCCESS -Log
    if ($Args) {
        Write-STStatus "ARGS: $($Args -join ' ')" -Level SUB -Log
    }

    if ($Simulate) {
        Write-STStatus "SIMULATING $Name" -Level INFO -Log
        if ($Args) {
            Write-STStatus "ARGS: $($Args -join ' ')" -Level SUB -Log
        }
        $count = Get-Random -Minimum 1 -Maximum 5
        $mock = for ($i = 1; $i -le $count; $i++) {
            [pscustomobject]@{ Id = $i; Value = (Get-Random) }
        }
        return $mock
    }

    if ($TranscriptPath) {
        Start-Transcript -Path $TranscriptPath -Append | Out-Null
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    $oldPref = $ErrorActionPreference
    $ErrorActionPreference = 'Stop'
    try {
        & $Path @Args
    } catch {
        Write-Error "Execution of '$Name' failed: $_"
        Write-STLog -Message "Execution of '$Name' failed: $_" -Level 'ERROR' -Structured -Metadata @{ version = $moduleVersion; script = $Name }
        $result = 'Failure'
        throw
    } finally {
        $ErrorActionPreference = $oldPref
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
        $sw.Stop()
        $duration = $sw.Elapsed
        Write-STLog -Metric 'Duration' -Value $duration.TotalSeconds
        $opId = [guid]::NewGuid().ToString()
        Write-STTelemetryEvent -ScriptName $Name -Result $result -Duration $duration -Category 'General' -OperationId $opId
        Send-STMetric -MetricName 'ExecutionSeconds' -Category 'General' -Value $duration.TotalSeconds -Details @{ Script = $Name; Result = $result; OperationId = $opId }
    }
    Write-STStatus "COMPLETED $Name" -Level FINAL -Log
}
