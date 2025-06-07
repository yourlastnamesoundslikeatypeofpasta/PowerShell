Describe 'AuditTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/AuditTools/AuditTools.psd1 -Force
    }

    It 'exports Summarize-AuditFindings' {
        (Get-Command -Module AuditTools).Name | Should -Contain 'Summarize-AuditFindings'
    }

    It 'sends audit data to the endpoint' {
        InModuleScope AuditTools {
            Mock Invoke-RestMethod { @{ choices = @(@{ message = @{ content = 'summary' } }) } }
            $data = @{ result = 'ok' }
            Summarize-AuditFindings -InputObject $data -EndpointUri 'https://test' -ApiKey 'key'
            Assert-MockCalled Invoke-RestMethod -ModuleName AuditTools -Times 1 -ParameterFilter { $Uri -eq 'https://test' }
        }
    }

    It 'writes HTML when Format Html' {
        InModuleScope AuditTools {
            Mock Invoke-RestMethod { @{ choices = @(@{ message = @{ content = 'summary' } }) } }
            $result = Summarize-AuditFindings -InputObject @{a=1} -EndpointUri 'https://test' -ApiKey 'k' -Format Html
            $result | Should -Match '<html>'
        }
    }
}
