. $PSScriptRoot/TestHelpers.ps1
Describe 'IncidentResponseTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/IncidentResponseTools/IncidentResponseTools.psd1 -Force
    }

    Safe-It 'exports Invoke-IncidentResponse' {
        (Get-Command -Module IncidentResponseTools).Name | Should -Contain 'Invoke-IncidentResponse'
    }

    Safe-It 'exports Invoke-RemoteAudit' {
        (Get-Command -Module IncidentResponseTools).Name | Should -Contain 'Invoke-RemoteAudit'
    }

    Safe-It 'exports Search-Indicators' {
        (Get-Command -Module IncidentResponseTools).Name | Should -Contain 'Search-Indicators'
    }
}
