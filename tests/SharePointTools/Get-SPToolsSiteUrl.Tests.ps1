Describe 'Get-SPToolsSiteUrl function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
    }
    It 'returns the matching URL' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ A='https://a'; B='https://b' } })
            Mock Write-SPToolsHacker {}
            Get-SPToolsSiteUrl -SiteName 'A' | Should -Be 'https://a'
        }
    }

    It 'does not accept pipeline input' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ B='https://b' } })
            Mock Write-SPToolsHacker {}
            { [pscustomobject]@{ SiteName='B' } | Get-SPToolsSiteUrl } | Should -Throw
        }
    }

    It 'throws when site is missing' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ A='https://a' } })
            Mock Write-SPToolsHacker {}
            { Get-SPToolsSiteUrl -SiteName 'C' } | Should -Throw
        }
    }

    It 'logs lookup messages' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ A='https://a' } })
            Mock Write-SPToolsHacker {}
            Get-SPToolsSiteUrl -SiteName 'A' | Out-Null
            Assert-MockCalled Write-SPToolsHacker -Times 1 -ParameterFilter { $Message -eq 'Looking up A' }
            Assert-MockCalled Write-SPToolsHacker -Times 1 -ParameterFilter { $Message -eq 'URL found: https://a' }
        }
    }
}
