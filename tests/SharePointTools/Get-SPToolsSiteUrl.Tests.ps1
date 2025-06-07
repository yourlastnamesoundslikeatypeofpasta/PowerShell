Describe 'Get-SPToolsSiteUrl function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
    }

    BeforeEach {
        InModuleScope SharePointTools {
            $SharePointToolsSettings = @{ Sites = @{ A='https://a'; B='https://b' } }
            Mock Write-SPToolsHacker {}
        }
    }

    It 'returns the matching URL' {
        InModuleScope SharePointTools {
            Get-SPToolsSiteUrl -SiteName 'A' | Should -Be 'https://a'
        }
    }

    It 'supports pipeline input' {
        InModuleScope SharePointTools {
            [pscustomobject]@{ SiteName='B' } | Get-SPToolsSiteUrl | Should -Be 'https://b'
        }
    }

    It 'throws when site is missing' {
        InModuleScope SharePointTools {
            { Get-SPToolsSiteUrl -SiteName 'C' } | Should -Throw
        }
    }

    It 'logs lookup messages' {
        InModuleScope SharePointTools {
            Get-SPToolsSiteUrl -SiteName 'A' | Out-Null
            Assert-MockCalled Write-SPToolsHacker -Times 1 -ParameterFilter { $Message -eq 'Looking up A' }
            Assert-MockCalled Write-SPToolsHacker -Times 1 -ParameterFilter { $Message -eq 'URL found: https://a' }
        }
    }
}
