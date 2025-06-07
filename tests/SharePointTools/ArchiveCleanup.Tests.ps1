Describe 'Invoke-ArchiveCleanup' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
    }
    BeforeEach {
        function Connect-PnPOnline {}
        function Get-PnPListItem {}
        function Remove-PnPFile {}
        function Remove-PnPFolder {}
        Mock Connect-PnPOnline {} -ModuleName SharePointTools
        Mock Get-PnPListItem { $script:testItems } -ModuleName SharePointTools
        Mock Remove-PnPFile {} -ModuleName SharePointTools
        Mock Remove-PnPFolder {} -ModuleName SharePointTools
        Mock Start-Transcript {}
        Mock Stop-Transcript {}
        Mock Get-SPToolsSiteUrl { 'https://contoso' } -ModuleName SharePointTools
    }
    It 'removes archived files and folders' {
        $script:testItems = @(
            [pscustomobject]@{ FileSystemObjectType='File'; FieldValues=@{ FileRef='Shared Documents/zzz_Archive/file.txt' } },
            [pscustomobject]@{ FileSystemObjectType='Folder'; FieldValues=@{ FileRef='Shared Documents/zzz_Archive/sub'; FileDirRef='Shared Documents/zzz_Archive'; FileLeafRef='sub' } }
        )
        Invoke-ArchiveCleanup -SiteName 'SiteA' -SiteUrl 'https://contoso' -Confirm:$false | Out-Null
        Assert-MockCalled Remove-PnPFile -Times 1 -ModuleName SharePointTools
        Assert-MockCalled Remove-PnPFolder -Times 1 -ModuleName SharePointTools
    }
}
