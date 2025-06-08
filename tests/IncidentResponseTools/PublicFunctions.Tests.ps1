. $PSScriptRoot/../TestHelpers.ps1

Describe 'IncidentResponseTools public functions' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/IncidentResponseTools/IncidentResponseTools.psd1 -Force
    }

    $wrappers = @{
        'Get-FailedLogin'       = 'Get-FailedLogins.ps1'
        'Get-NetworkShare'      = 'Get-NetworkShares.ps1'
        'Invoke-IncidentResponse' = 'Invoke-IncidentResponse.ps1'
        'Search-Indicators'     = 'Search-Indicators.ps1'
        'Submit-SystemInfoTicket' = 'Submit-SystemInfoTicket.ps1'
        'Update-Sysmon'         = 'Update-Sysmon.ps1'
    }

    Safe-It 'calls Invoke-ScriptFile' -ForEach $wrappers.GetEnumerator() {
        param($case)
        InModuleScope IncidentResponseTools {
            Mock Invoke-ScriptFile {} -ModuleName IncidentResponseTools
            switch ($case.Key) {
                'Submit-SystemInfoTicket' { & $case.Key -SiteName 'A' -RequesterEmail 'r@c.com' }
                default { & $case.Key }
            }
            Assert-MockCalled Invoke-ScriptFile -ModuleName IncidentResponseTools -Times 1 -ParameterFilter { $Name -eq $case.Value }
        }
    }

    Safe-It 'throws when Invoke-ScriptFile fails' -ForEach $wrappers.GetEnumerator() {
        param($case)
        InModuleScope IncidentResponseTools {
            Mock Invoke-ScriptFile { throw 'fail' } -ModuleName IncidentResponseTools
            switch ($case.Key) {
                'Submit-SystemInfoTicket' { { & $case.Key -SiteName 'A' -RequesterEmail 'r@c.com' } | Should -Throw }
                default { { & $case.Key } | Should -Throw }
            }
        }
    }

    Context 'Get-CommonSystemInfo' {
        It 'returns system info when CIM available' {
            InModuleScope IncidentResponseTools {
                Mock Get-Command { @{ Name='Get-CimInstance' } } -ParameterFilter { $Name -eq 'Get-CimInstance' }
                Mock Get-Command { $null } -ParameterFilter { $Name -eq 'Get-WmiObject' }
                Mock Get-CimInstance {
                    switch ($ClassName) {
                        'Win32_OperatingSystem' { [pscustomobject]@{ CSName='PC'; Caption='OS'; BuildNumber='1'; TotalVisibleMemorySize=2048 } }
                        'Win32_Processor'       { [pscustomobject]@{ Name='CPU' } }
                        'Win32_LogicalDisk'     { @([pscustomobject]@{ DeviceID='C:'; Size=100GB; FreeSpace=50GB }) }
                        default { @() }
                    }
                }
                Mock Write-STStatus {}
                Mock Send-STMetric {}
                $res = Get-CommonSystemInfo
                $res.ComputerName | Should -Be 'PC'
                Assert-MockCalled Send-STMetric -ParameterFilter { $MetricName -eq 'Get-CommonSystemInfo' } -Times 1
            }
        }
        It 'returns error object on failure' {
            InModuleScope IncidentResponseTools {
                Mock Get-Command { @{ Name='Get-CimInstance' } } -ParameterFilter { $Name -eq 'Get-CimInstance' }
                Mock Get-CimInstance { throw 'bad' }
                Mock Write-STStatus {}
                Mock Write-STLog {}
                Mock Send-STMetric {}
                $res = Get-CommonSystemInfo
                $res.Category | Should -Be 'WMI'
            }
        }
    }

    Context 'Invoke-RemoteAudit' {
        It 'collects info from computers' {
            InModuleScope IncidentResponseTools {
                Mock Invoke-Command { [pscustomobject]@{ ComputerName=$ComputerName; Info='i' } }
                $r = Invoke-RemoteAudit -ComputerName 'PC1'
                $r.Success | Should -BeTrue
                $r.Info | Should -Be 'i'
            }
        }
        It 'captures errors from Invoke-Command' {
            InModuleScope IncidentResponseTools {
                Mock Invoke-Command { throw 'fail' }
                $r = Invoke-RemoteAudit -ComputerName 'PC1'
                $r.Success | Should -BeFalse
                $r.Error | Should -Match 'fail'
            }
        }
    }

    Context 'Invoke-FullSystemAudit' {
        It 'aggregates step output' {
            InModuleScope IncidentResponseTools {
                Mock Get-CommonSystemInfo { 'info' }
                Mock Get-FailedLogin { 'fails' }
                Mock Invoke-ScriptFile { 'sp' } -ParameterFilter { $Name -eq 'Generate-SPUsageReport.ps1' }
                Mock Invoke-ScriptFile { 'perf' } -ParameterFilter { $Name -eq 'Invoke-PerformanceAudit.ps1' }
                $s = Invoke-FullSystemAudit -OutputPath (Join-Path $env:TEMP 'o.json')
                $s.CommonSystemInfo | Should -Be 'info'
                $s.Errors.Count | Should -Be 0
            }
        }
        It 'records errors when steps fail' {
            InModuleScope IncidentResponseTools {
                Mock Get-CommonSystemInfo { throw 'boom' }
                Mock Get-FailedLogin { 'fails' }
                Mock Invoke-ScriptFile { 'sp' } -ParameterFilter { $Name -eq 'Generate-SPUsageReport.ps1' }
                Mock Invoke-ScriptFile { 'perf' } -ParameterFilter { $Name -eq 'Invoke-PerformanceAudit.ps1' }
                $s = Invoke-FullSystemAudit -OutputPath (Join-Path $env:TEMP 'o.json')
                $s.Errors.Count | Should -Be 1
            }
        }
    }
}
