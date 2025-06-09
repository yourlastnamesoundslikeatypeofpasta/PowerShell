. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-EventLogSummary function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/MonitoringTools/MonitoringTools.psd1 -Force
    }

    Safe-It 'summarises events using Get-WinEvent' {
        InModuleScope MonitoringTools {
            Mock Get-Command { @{ Name = 'Get-WinEvent' } } -ParameterFilter { $Name -eq 'Get-WinEvent' }
            Mock Get-WinEvent { @([pscustomobject]@{ LevelDisplayName = 'Error' }) }
            Mock Write-STRichLog {}
            $result = Get-EventLogSummary -LogName 'System' -LastHours 1
            $result[0].Name | Should -Be 'Error'
            $result[0].Count | Should -Be 1
        }
    }

    Safe-It 'falls back to Get-EventLog when Get-WinEvent missing' {
        InModuleScope MonitoringTools {
            Mock Get-Command {
                if ($Name -eq 'Get-WinEvent') { $null } else { @{ Name = 'Get-EventLog' } }
            }
            Mock Get-EventLog { @([pscustomobject]@{ EntryType = 'Warning' }) }
            Mock Write-STRichLog {}
            $result = Get-EventLogSummary -LastHours 1
            $result[0].Name | Should -Be 'Warning'
            $result[0].Count | Should -Be 1
        }
    }

    Safe-It 'logs warning when no event cmdlets found' {
        InModuleScope MonitoringTools {
            Mock Get-Command { $null }
            Mock Write-Warning {}
            Mock Write-STRichLog {}
            $null = Get-EventLogSummary
            Assert-MockCalled Write-Warning -Times 1
        }
    }

    Safe-It 'validates LastHours range' {
        { Get-EventLogSummary -LastHours 0 } | Should -Throw
    }
}
