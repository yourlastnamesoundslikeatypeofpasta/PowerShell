Describe 'Invoke-ArchiveCleanup' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/SharePointTools/SharePointTools.psd1 -Force
    }
    BeforeEach {
        InModuleScope SharePointTools {
            function Connect-PnPOnline {}
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
        }
    }
    It 'removes archived files and folders' {
        InModuleScope SharePointTools {
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
