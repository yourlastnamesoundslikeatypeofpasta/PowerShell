$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
$loggingModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'Logging/Logging.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue

function Send-STMetric {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$MetricName,
        [Parameter(Mandatory)][string]$Category,
        [Parameter(Mandatory)][double]$Value,
        [hashtable]$Details
    )
    Assert-ParameterNotNull $MetricName 'MetricName'
    Assert-ParameterNotNull $Category 'Category'
    Assert-ParameterNotNull $Value 'Value'
    if ($env:ST_ENABLE_TELEMETRY -ne '1') { Write-STDebug 'Telemetry disabled'; return }

    $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
    if ($env:ST_TELEMETRY_PATH) {
        $logFile = $env:ST_TELEMETRY_PATH
    } else {
        $dir = Join-Path $userProfile 'SupportToolsTelemetry'
        $logFile = Join-Path $dir 'telemetry.jsonl'
    }
    $dir = Split-Path -Path $logFile -Parent
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }

    $entry = [ordered]@{
        Timestamp   = (Get-Date).ToString('o')
        OperationId = [guid]::NewGuid().ToString()
        MetricName  = $MetricName
        Category    = $Category
        Value       = $Value
    }
    if ($Details) { $entry.Details = $Details }

    ($entry | ConvertTo-Json -Depth 5 -Compress) | Out-File -FilePath $logFile -Append -Encoding utf8
    return $entry
}

function Write-STTelemetryEvent {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$ScriptName,
        [Parameter(Mandatory)][string]$Result,
        [Parameter(Mandatory)][timespan]$Duration,
        [string]$Category = 'General',
        [string]$OperationId
    )
    Assert-ParameterNotNull $ScriptName 'ScriptName'
    Assert-ParameterNotNull $Result 'Result'
    Assert-ParameterNotNull $Duration 'Duration'
    if ($env:ST_ENABLE_TELEMETRY -ne '1') { Write-STDebug 'Telemetry disabled'; return }

    $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
    if ($env:ST_TELEMETRY_PATH) {
        $logFile = $env:ST_TELEMETRY_PATH
    } else {
        $dir = Join-Path $userProfile 'SupportToolsTelemetry'
        $logFile = Join-Path $dir 'telemetry.jsonl'
    }
    $dir = Split-Path -Path $logFile -Parent
    if (-not (Test-Path $dir)) {
        New-Item -Path $dir -ItemType Directory -Force | Out-Null
    }
    if (-not $OperationId) { $OperationId = [guid]::NewGuid().ToString() }
    $event = [ordered]@{
        Timestamp   = (Get-Date).ToString('o')
        OperationId = $OperationId
        Script      = $ScriptName
        Result      = $Result
        Duration    = [math]::Round($Duration.TotalSeconds, 2)
        Category    = $Category
    } | ConvertTo-Json -Compress

    $event | Out-File -FilePath $logFile -Encoding utf8 -Append
}

function Get-STTelemetryMetrics {
    [CmdletBinding()]
    param(
        [string]$LogPath,
        [string]$CsvPath,
        [string]$SqlitePath
    )

    if ($LogPath) { $logFile = $LogPath }
    elseif ($env:ST_TELEMETRY_PATH) { $logFile = $env:ST_TELEMETRY_PATH }
    else {
        $userProfile = if ($env:USERPROFILE) { $env:USERPROFILE } else { $env:HOME }
        $dir = Join-Path $userProfile 'SupportToolsTelemetry'
        $logFile = Join-Path $dir 'telemetry.jsonl'
    }

    if (-not (Test-Path $logFile)) {
        throw "Telemetry log file not found: $logFile"
    }

    $events = Get-Content $logFile | ForEach-Object { $_ | ConvertFrom-Json }
    if (-not $events) { return @() }

    $metrics = foreach ($group in ($events | Group-Object -Property Script)) {
        $avg = ($group.Group.Duration | Measure-Object -Average).Average
        [pscustomobject]@{
            Script         = $group.Name
            Executions     = $group.Count
            Successes      = ($group.Group | Where-Object Result -eq 'Success').Count
            Failures       = ($group.Group | Where-Object Result -eq 'Failure').Count
            AverageSeconds = [math]::Round($avg, 2)
            LastRun        = ($group.Group | Sort-Object Timestamp -Descending | Select-Object -First 1).Timestamp
        }
    }

    if ($CsvPath) {
        $metrics | Export-Csv -NoTypeInformation -Path $CsvPath
    }

    if ($SqlitePath) {
        if (-not (Get-Command sqlite3 -ErrorAction SilentlyContinue)) {
            throw 'sqlite3 command not found'
        }
        & sqlite3 $SqlitePath "CREATE TABLE IF NOT EXISTS metrics (Script TEXT PRIMARY KEY, Executions INTEGER, Successes INTEGER, Failures INTEGER, AverageSeconds REAL, LastRun TEXT);"
        foreach ($m in $metrics) {
            $script = $m.Script -replace "'","''"
            $sql = "INSERT OR REPLACE INTO metrics (Script,Executions,Successes,Failures,AverageSeconds,LastRun) VALUES ('$script',$($m.Executions),$($m.Successes),$($m.Failures),$($m.AverageSeconds),'$($m.LastRun)');"
            & sqlite3 $SqlitePath $sql
        }
    }

    return $metrics
}

Export-ModuleMember -Function 'Write-STTelemetryEvent','Get-STTelemetryMetrics','Send-STMetric'

function Show-TelemetryBanner {
    Write-STDivider 'TELEMETRY MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module Telemetry' to view available tools." -Level SUB
    Write-STLog -Message 'Telemetry module loaded'
}

Show-TelemetryBanner
