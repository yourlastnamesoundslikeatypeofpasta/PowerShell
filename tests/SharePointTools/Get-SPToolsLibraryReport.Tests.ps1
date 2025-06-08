Describe 'Get-SPToolsLibraryReport parameters' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
    }
    It 'uses Get-SPToolsSiteUrl when SiteUrl not specified' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ A='https://contoso' }; ClientId='id'; TenantId='tid'; CertPath='c' })
            function Connect-PnPOnline { param($Url,$ClientId,$TenantId,$CertificatePath) }
            function Get-PnPList {}
            function Disconnect-PnPOnline {}
            Mock Connect-PnPOnline {}
            Mock Disconnect-PnPOnline {}
            Mock Get-PnPList { @([pscustomobject]@{ Title='Docs'; BaseTemplate=101; ItemCount=1; LastItemUserModifiedDate='2023-01-01' }) }
            Mock Get-SPToolsSiteUrl { 'https://contoso' }
            Get-SPToolsLibraryReport -SiteName 'A' | Out-Null
            Assert-MockCalled Get-SPToolsSiteUrl -Times 1
        }
    }
    It 'SiteName is mandatory' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ A='https://contoso' }; ClientId='id'; TenantId='tid'; CertPath='c' })
            $meta = Get-Command Get-SPToolsLibraryReport
            $attr = $meta.Parameters['SiteName'].Attributes | Where-Object { $_ -is [System.Management.Automation.ParameterAttribute] }
            $attr.Mandatory | Should -BeTrue
        }
    }
    It 'throws when PnP command fails' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ A='https://c' }; ClientId='id'; TenantId='tid'; CertPath='c' })
            function Connect-PnPOnline { param($Url,$ClientId,$TenantId,$CertificatePath) }
            function Get-PnPList {}
            function Disconnect-PnPOnline {}
            Mock Connect-PnPOnline {}
            Mock Disconnect-PnPOnline {}
            Mock Get-PnPList { throw 'fail' }
            { Get-SPToolsLibraryReport -SiteName 'A' -SiteUrl 'https://c' } | Should -Throw
        }
    }
}
