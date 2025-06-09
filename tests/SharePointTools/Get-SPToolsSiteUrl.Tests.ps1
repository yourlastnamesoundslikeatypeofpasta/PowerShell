. $PSScriptRoot/../TestHelpers.ps1
Describe 'Get-SPToolsSiteUrl function' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
    }
    Safe-It 'returns the matching URL' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ A = 'https://a'; B = 'https://b' } })
            Mock Write-SPToolsHacker {}
            Get-SPToolsSiteUrl -SiteName 'A' | Should -Be 'https://a'
        }
    }

    Safe-It 'parameter does not accept pipeline input' {
        InModuleScope SharePointTools {
            $meta = Get-Command Get-SPToolsSiteUrl
            $paramAttr = $meta.Parameters['SiteName'].Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
            $paramAttr.ValueFromPipeline | Should -BeFalse
            $paramAttr.ValueFromPipelineByPropertyName | Should -BeFalse
        }
    }

    Safe-It 'throws when site is missing' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ A = 'https://a' } })
            Mock Write-SPToolsHacker {}
            { Get-SPToolsSiteUrl -SiteName 'C' } | Should -Throw
        }
    }

    Safe-It 'logs lookup messages' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ A = 'https://a' } })
            Mock Write-SPToolsHacker {}
            Get-SPToolsSiteUrl -SiteName 'A' | Out-Null
            Assert-MockCalled Write-SPToolsHacker -Times 1 -ParameterFilter { $Message -eq 'Looking up A' }
            Assert-MockCalled Write-SPToolsHacker -Times 1 -ParameterFilter { $Message -eq 'URL found: https://a' }
        }
    }
}
