function Invoke-FullSystemAudit {
    <#
    .SYNOPSIS
        Runs common audit scripts and summarizes the results.
    .DESCRIPTION
        Executes Get-CommonSystemInfo, Generate-SPUsageReport, Get-FailedLogin and Invoke-PerformanceAudit in sequence.
        Progress and errors are logged, telemetry recorded, and a combined report is saved as JSON or HTML.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$OutputPath,
        [Parameter(Mandatory = $false)]
        [switch]$Html,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath,
        [Parameter(Mandatory = $false)]
        [switch]$Simulate,
        [Parameter(Mandatory = $false)]
        [switch]$Explain
        ,[Parameter(Mandatory = $false)]
        [object]$Logger
        ,[Parameter(Mandatory = $false)]
        [object]$TelemetryClient
        ,[Parameter(Mandatory = $false)]
        [object]$Config
    )

    process {
        if ($Logger) { Import-Module $Logger -ErrorAction SilentlyContinue }
        if ($TelemetryClient) {
            Import-Module $TelemetryClient -ErrorAction SilentlyContinue
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Telemetry/Telemetry.psd1') -ErrorAction SilentlyContinue
        }
        if ($Config) { Import-Module $Config -ErrorAction SilentlyContinue }
        if (-not $OutputPath) {
            $ext = if ($Html) { 'html' } else { 'json' }
            $OutputPath = Join-Path (Get-Location) "SystemAudit_$((Get-Date).ToString('yyyyMMdd_HHmmss')).$ext"
        }

        $summary = [ordered]@{}
        $errors  = @()

        function Run-Step {
            param(
                [string]$Name,
                [scriptblock]$Action
            )
            Write-STStatus "Starting $Name" -Level INFO -Log
            $sw = [System.Diagnostics.Stopwatch]::StartNew()
            $result = 'Success'
            $out = $null
            try {
                $out = & $Action
                Write-STStatus "Completed $Name" -Level SUCCESS -Log
            } catch {
                Write-STStatus "$Name failed: $_" -Level ERROR -Log
                $errors += [pscustomobject]@{ Stage = $Name; Error = $_.ToString() }
                $result = 'Failure'
            } finally {
                $sw.Stop()
                $opId = [guid]::NewGuid().ToString()
                Write-STTelemetryEvent -ScriptName $Name -Result $result -Duration $sw.Elapsed -Category 'Audit' -OperationId $opId
                Send-STMetric -MetricName $Name -Category 'Audit' -Value $sw.Elapsed.TotalSeconds -Details @{ Result = $result; OperationId = $opId }
            }
            return $out
        }

        $summary.CommonSystemInfo = Run-Step 'Get-CommonSystemInfo' { Get-CommonSystemInfo }
        $summary.SPUsageReport    = Run-Step 'Generate-SPUsageReport' {
            Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Generate-SPUsageReport.ps1' -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        }
        $summary.FailedLogin      = Run-Step 'Get-FailedLogin' { Get-FailedLogin }
        $summary.PerformanceAudit = Run-Step 'Invoke-PerformanceAudit' {
            Invoke-ScriptFile -Logger $Logger -TelemetryClient $TelemetryClient -Config $Config -Name 'Invoke-PerformanceAudit.ps1' -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain
        }

        $summary.Errors = $errors

        if ($Html) {
            $summary | ConvertTo-Html -PreContent '<h1>Full System Audit</h1>' | Out-File -FilePath $OutputPath -Encoding utf8
        } else {
            $summary | ConvertTo-Json -Depth 5 | Out-File -FilePath $OutputPath -Encoding utf8
        }

        Write-STStatus "Summary saved to $OutputPath" -Level SUCCESS -Log
        return $summary
    }
}
