. $PSScriptRoot/TestHelpers.ps1

Describe 'Invoke-DailyAuditWorkflow.ps1 script' {
    BeforeAll {
        $ScriptPath = Join-Path $PSScriptRoot/.. 'scripts/Invoke-DailyAuditWorkflow.ps1'
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/SharePointTools/SharePointTools.psd1 -Force
        Import-Module $PSScriptRoot/../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
    }

    BeforeEach {
        $script:order = @()
        Mock Write-STStatus {}
        Mock Get-SPPermissionsReport {
            $script:order += 'Get-SPPermissionsReport'
            @([pscustomobject]@{ User='U' })
        }
        Mock Export-Csv {
            $script:order += 'Export-Csv'
        }
        Mock New-SDTicket {
            $script:order += 'New-SDTicket'
            @{ id = 1 }
        }
        Mock Write-STTelemetryEvent {
            $script:order += 'Write-STTelemetryEvent'
        }
        # Mock internal scripts if called
        function Invoke-IncidentResponse {}
        function Invoke-PerformanceAudit {}
    }

    Safe-It 'runs the workflow and records telemetry' {
        & $ScriptPath -SiteUrl 'https://contoso.sharepoint.com' -RequesterEmail 'admin@contoso.com' | Out-Null
        $script:order | Should -Be @('Get-SPPermissionsReport','Export-Csv','New-SDTicket','Write-STTelemetryEvent')
        Assert-MockCalled Write-STTelemetryEvent -Times 1
    }
}
