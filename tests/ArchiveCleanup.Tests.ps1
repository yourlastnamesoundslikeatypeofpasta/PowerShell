Describe 'Invoke-ArchiveCleanup' {
    BeforeAll {
        $env:SPTOOLS_CLIENT_ID = 'id'
        $env:SPTOOLS_TENANT_ID = 'tid'
        $env:SPTOOLS_CERT_PATH = 'c'
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../src/SharePointTools/SharePointTools.psd1 -Force
    }
    BeforeEach {
        $env:SPTOOLS_CLIENT_ID = 'id'
        $env:SPTOOLS_TENANT_ID = 'tid'
        $env:SPTOOLS_CERT_PATH = 'c'
    }
    It 'removes archived files and folders' {
        InModuleScope SharePointTools {
            function Connect-PnPOnline { param($Url,$ClientId,$TenantId,$CertificatePath) }
            function Get-PnPListItem { $script:testItems }
            function Remove-PnPFile {}
            function Remove-PnPFolder {}
            Mock Connect-PnPOnline {}
            Mock Get-PnPListItem { $script:testItems }
            Mock Remove-PnPFile {}
            Mock Remove-PnPFolder {}
            Mock Start-Transcript {}
            Mock Stop-Transcript {}
            Mock Get-SPToolsSiteUrl { 'https://contoso' }
            $script:testItems = @(
                [pscustomobject]@{ FileSystemObjectType='File'; FieldValues=@{ FileRef='Shared Documents/zzz_Archive/file.txt' } },
                [pscustomobject]@{ FileSystemObjectType='Folder'; FieldValues=@{ FileRef='Shared Documents/zzz_Archive/sub'; FileDirRef='Shared Documents/zzz_Archive'; FileLeafRef='sub' } }
            )
            Invoke-ArchiveCleanup -SiteName 'SiteA' -SiteUrl 'https://contoso' -Confirm:$false | Out-Null
            Assert-MockCalled Remove-PnPFile -Times 1
            Assert-MockCalled Remove-PnPFolder -Times 1
        }
    }
}
