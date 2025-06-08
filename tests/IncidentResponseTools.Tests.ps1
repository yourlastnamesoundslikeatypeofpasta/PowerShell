Describe 'IncidentResponseTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/IncidentResponseTools/IncidentResponseTools.psd1 -Force
    }

    It 'exports Invoke-IncidentResponse' {
        (Get-Command -Module IncidentResponseTools).Name | Should -Contain 'Invoke-IncidentResponse'
    }

    It 'exports Invoke-RemoteAudit' {
        (Get-Command -Module IncidentResponseTools).Name | Should -Contain 'Invoke-RemoteAudit'
    }

    It 'exports Search-Indicators' {
        (Get-Command -Module IncidentResponseTools).Name | Should -Contain 'Search-Indicators'
    }
}
