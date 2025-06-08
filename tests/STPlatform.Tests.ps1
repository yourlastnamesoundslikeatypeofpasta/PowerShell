Describe 'STPlatform Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/Telemetry/Telemetry.psd1 -Force
        Import-Module $PSScriptRoot/../src/STPlatform/STPlatform.psd1 -Force
    }

    It 'exports Connect-STPlatform' {
        (Get-Command -Module STPlatform).Name | Should -Contain 'Connect-STPlatform'
    }

    Context 'Connect-STPlatform telemetry' {
        $cases = @(
            @{ Mode='Cloud';  Modules=@('Microsoft.Graph','ExchangeOnlineManagement'); Graph=1; Online=1; Server=0 },
            @{ Mode='Hybrid'; Modules=@('Microsoft.Graph','ExchangeOnlineManagement','ActiveDirectory'); Graph=1; Online=1; Server=0 },
            @{ Mode='OnPrem'; Modules=@('ActiveDirectory','ExchangePowerShell'); Graph=0; Online=0; Server=1 }
        )

        It 'records telemetry and connects in <Mode> mode' -ForEach $cases {
            param($case)
            $log = Join-Path ([System.IO.Path]::GetTempPath()) ([System.IO.Path]::GetRandomFileName())
            try {
                $env:ST_ENABLE_TELEMETRY = '1'
                $env:ST_TELEMETRY_PATH = $log
                InModuleScope STPlatform {
                    foreach ($m in $using:case.Modules) { Mock Install-Module {} -ParameterFilter { $Name -eq $using:m } }
                    Mock Import-Module {}
                    Mock Get-Module { $null }
                    Mock Write-STStatus {}
                    Mock Connect-MgGraph {}
                    Mock Connect-ExchangeOnline {}
                    Mock Connect-ExchangeServer {}
                    if ($using:case.Server -eq 1) {
                        Mock Get-Command { @{ Name='Connect-ExchangeServer' } } -ParameterFilter { $Name -eq 'Connect-ExchangeServer' }
                    } else {
                        Mock Get-Command { $null } -ParameterFilter { $Name -eq 'Connect-ExchangeServer' }
                    }

                    Connect-STPlatform -Mode $using:case.Mode -InstallMissing

                    foreach ($m in $using:case.Modules) { Assert-MockCalled Install-Module -ParameterFilter { $Name -eq $using:m } -Times 1 }
                    Assert-MockCalled Import-Module -Times $using:case.Modules.Count
                    Assert-MockCalled Connect-MgGraph -Times $using:case.Graph
                    Assert-MockCalled Connect-ExchangeOnline -Times $using:case.Online
                    Assert-MockCalled Connect-ExchangeServer -Times $using:case.Server
                }

                (Get-Content $log | Measure-Object -Line).Lines | Should -Be 1
                $json = Get-Content $log | ConvertFrom-Json
                $json.MetricName | Should -Be 'Connect-STPlatform'
                $json.Details.Mode | Should -Be $case.Mode
                $json.Details.Result | Should -Be 'Success'
            } finally {
                Remove-Item $log -ErrorAction SilentlyContinue
                Remove-Item env:ST_ENABLE_TELEMETRY -ErrorAction SilentlyContinue
                Remove-Item env:ST_TELEMETRY_PATH -ErrorAction SilentlyContinue
            }
        }
    }
}
