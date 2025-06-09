. $PSScriptRoot/../TestHelpers.ps1

Describe 'Get-DiskSpaceInfo function' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../../src/MonitoringTools/MonitoringTools.psd1 -Force
    }

    Safe-It 'returns disk information' {
        InModuleScope MonitoringTools {
            Mock Get-CimInstance { [pscustomobject]@{ DeviceID = 'C:'; Size = 1GB; FreeSpace = 512MB } }
            Mock Write-STRichLog {}
            $result = Get-DiskSpaceInfo
            $result[0].Drive | Should -Be 'C:'
        }
    }

    Safe-It 'writes transcript when TranscriptPath used' {
        InModuleScope MonitoringTools {
            Mock Get-CimInstance { @() }
            Mock Start-Transcript {}
            Mock Stop-Transcript {}
            Mock Write-STRichLog {}
            Get-DiskSpaceInfo -TranscriptPath 'log.txt'
            Assert-MockCalled Start-Transcript -Times 1
            Assert-MockCalled Stop-Transcript -Times 1
        }
    }

    Safe-It 'returns error record on failure' {
        InModuleScope MonitoringTools {
            Mock Get-CimInstance { throw 'bad' }
            Mock Write-STRichLog {}
            $result = Get-DiskSpaceInfo
            $result | Should -BeOfType 'System.Management.Automation.ErrorRecord'
        }
    }
}
