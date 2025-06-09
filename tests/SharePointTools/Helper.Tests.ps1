. $PSScriptRoot/../TestHelpers.ps1
Describe 'SharePointTools helper functions' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
    }
    Safe-It 'Connect-SPToolsOnline retries until success' {
        InModuleScope SharePointTools {
            $script:attempt = 0
            function Connect-PnPOnline {}
            Mock Connect-PnPOnline {
                if ($script:attempt -lt 1) { $script:attempt++; throw 'fail' }
            }
            Mock Start-Sleep {}
            Connect-SPToolsOnline -Url 'https://contoso' -ClientId id -TenantId tid -CertPath cert
            Assert-MockCalled Connect-PnPOnline -Times 2
        }
    }
    Safe-It 'Invoke-SPPnPCommand rethrows errors' {
        InModuleScope SharePointTools {
            { Invoke-SPPnPCommand { throw 'boom' } -ErrorMessage 'fail' } | Should -Throw
        }
    }
    Safe-It 'Register-SPToolsCompleters registers completer commands' {
        InModuleScope SharePointTools {
            Mock Register-ArgumentCompleter {}
            Register-SPToolsCompleters
            Assert-MockCalled Register-ArgumentCompleter -Times 2
        }
    }

    Safe-It 'Save-SPToolsSettings uses default path when none specified' {
        InModuleScope SharePointTools {
            $temp = [System.IO.Path]::GetTempFileName()
            $script:settingsFile = $temp
            $SharePointToolsSettings = @{ A = 1 }
            Mock Out-File {}
            Mock Write-SPToolsHacker {}
            Save-SPToolsSettings
            Assert-MockCalled Out-File -Times 1 -ParameterFilter { $FilePath -eq $temp }
            Remove-Item $temp -ErrorAction SilentlyContinue
        }
    }

    Safe-It 'Save-SPToolsSettings accepts custom path' {
        InModuleScope SharePointTools {
            $temp = [System.IO.Path]::GetTempFileName()
            $SharePointToolsSettings = @{ A = 1 }
            Mock Out-File {}
            Mock Write-SPToolsHacker {}
            Save-SPToolsSettings -Path $temp
            Assert-MockCalled Out-File -Times 1 -ParameterFilter { $FilePath -eq $temp }
            Remove-Item $temp -ErrorAction SilentlyContinue
        }
    }
}
