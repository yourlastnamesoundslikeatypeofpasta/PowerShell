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
        [string]$OutputPath,
        [switch]$Html,
        [string]$TranscriptPath,
        [switch]$Simulate,
        [switch]$Explain
    )

    process {
        Import-Module (Join-Path $PSScriptRoot '../../Telemetry/Telemetry.psd1') -ErrorAction SilentlyContinue
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
                Write-STTelemetryEvent -ScriptName $Name -Result $result -Duration $sw.Elapsed
            }
            return $out
        }

        $summary.CommonSystemInfo = Run-Step 'Get-CommonSystemInfo' { Get-CommonSystemInfo }
        $summary.SPUsageReport    = Run-Step 'Generate-SPUsageReport' { Invoke-ScriptFile -Name 'Generate-SPUsageReport.ps1' -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain }
        $summary.FailedLogin      = Run-Step 'Get-FailedLogin' { Get-FailedLogin }
        $summary.PerformanceAudit = Run-Step 'Invoke-PerformanceAudit' { Invoke-ScriptFile -Name 'Invoke-PerformanceAudit.ps1' -TranscriptPath $TranscriptPath -Simulate:$Simulate -Explain:$Explain }

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
