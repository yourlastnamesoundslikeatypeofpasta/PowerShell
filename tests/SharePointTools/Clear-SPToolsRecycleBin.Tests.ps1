Describe 'Clear-SPToolsRecycleBin command' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
    }
    It 'invokes second stage clearing when requested' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ A='https://c' }; ClientId='id'; TenantId='tid'; CertPath='c' })
            function Connect-PnPOnline { param($Url,$ClientId,$TenantId,$CertificatePath) }
            function Clear-PnPRecycleBinItem { param([switch]$FirstStage,[switch]$SecondStage,[switch]$Force) }
            function Disconnect-PnPOnline {}
            Mock Connect-PnPOnline {}
            Mock Disconnect-PnPOnline {}
            Mock Clear-PnPRecycleBinItem {} -ModuleName SharePointTools
            Clear-SPToolsRecycleBin -SiteName 'A' -SiteUrl 'https://c' -SecondStage -Confirm:$false
            Assert-MockCalled Clear-PnPRecycleBinItem -ModuleName SharePointTools -ParameterFilter { $SecondStage -and -not $FirstStage } -Times 1
        }
    }
    It 'logs error when recycle bin clear fails' {
        InModuleScope SharePointTools {
            $ExecutionContext.SessionState.PSVariable.Set('SharePointToolsSettings', @{ Sites = @{ A='https://c' }; ClientId='id'; TenantId='tid'; CertPath='c' })
            function Connect-PnPOnline { param($Url,$ClientId,$TenantId,$CertificatePath) }
            function Clear-PnPRecycleBinItem { param([switch]$FirstStage,[switch]$SecondStage,[switch]$Force) }
            function Disconnect-PnPOnline {}
            Mock Connect-PnPOnline {}
            Mock Disconnect-PnPOnline {}
            Mock Clear-PnPRecycleBinItem { throw "fail" }
            Mock Write-STStatus {} -ParameterFilter { $Message -like 'Failed to clear recycle bin*' }
            Clear-SPToolsRecycleBin -SiteName 'A' -SiteUrl 'https://c' -Confirm:$false
            Assert-MockCalled Write-STStatus -ParameterFilter { $Message -like 'Failed to clear recycle bin*' } -Times 1
        }
    }
}
