. $PSScriptRoot/../TestHelpers.ps1
Describe 'Test-Drift function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/ConfigManagementTools/ConfigManagementTools.psd1 -Force
    }

    Safe-It 'detects configuration drift' {
        InModuleScope ConfigManagementTools {
            $baseline = @{ timezone='UTC'; hostname='HOST1'; services=@{ svc1='Running' } }
            $file = [System.IO.Path]::GetTempFileName()
            $baseline | ConvertTo-Json | Set-Content -Path $file
            Mock Get-TimeZone { [pscustomobject]@{ Id='EST' } }
            Mock Get-Service { [pscustomobject]@{ Status='Stopped' } }
            $env:COMPUTERNAME = 'HOST2'
            try {
                $result = Test-Drift -BaselinePath $file
                $result.Count | Should -Be 3
            } finally {
                Remove-Item $file -ErrorAction SilentlyContinue
            }
        }
    }

    Safe-It 'returns empty when system matches baseline' {
        InModuleScope ConfigManagementTools {
            $baseline = @{ timezone='UTC'; hostname='HOST1'; services=@{ svc1='Running' } }
            $file = [System.IO.Path]::GetTempFileName()
            $baseline | ConvertTo-Json | Set-Content -Path $file
            Mock Get-TimeZone { [pscustomobject]@{ Id='UTC' } }
            Mock Get-Service { [pscustomobject]@{ Status='Running' } }
            $env:COMPUTERNAME = 'HOST1'
            try {
                $result = Test-Drift -BaselinePath $file
                $result.Count | Should -Be 0
            } finally {
                Remove-Item $file -ErrorAction SilentlyContinue
            }
        }
    }

    Safe-It 'accepts baseline file from pipeline' {
        InModuleScope ConfigManagementTools {
            $baseline = @{ timezone='UTC'; hostname='HOST1'; services=@{ svc1='Running' } }
            $file = [System.IO.Path]::GetTempFileName()
            $baseline | ConvertTo-Json | Set-Content -Path $file
            Mock Get-TimeZone { [pscustomobject]@{ Id='EST' } }
            Mock Get-Service { [pscustomobject]@{ Status='Stopped' } }
            $env:COMPUTERNAME = 'HOST2'
            try {
                $result = [pscustomobject]@{ BaselinePath = $file } | Test-Drift
                $result.Count | Should -Be 3
            } finally {
                Remove-Item $file -ErrorAction SilentlyContinue
            }
        }
    }
}
