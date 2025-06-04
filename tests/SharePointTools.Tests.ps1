Describe 'SharePointTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/SharePointTools/SharePointTools.psd1 -Force
    }

    Context 'Exported commands' {
        $expected = @(
            'Invoke-YFArchiveCleanup',
            'Invoke-IBCCentralFilesArchiveCleanup',
            'Invoke-MexCentralFilesArchiveCleanup',
            'Invoke-ArchiveCleanup',
            'Invoke-YFFileVersionCleanup',
            'Invoke-IBCCentralFilesFileVersionCleanup',
            'Invoke-MexCentralFilesFileVersionCleanup',
            'Invoke-FileVersionCleanup',
            'Invoke-SharingLinkCleanup',
            'Invoke-YFSharingLinkCleanup',
            'Invoke-IBCCentralFilesSharingLinkCleanup',
            'Invoke-MexCentralFilesSharingLinkCleanup'
        )
        $exported = (Get-Command -Module SharePointTools).Name
        foreach ($cmd in $expected) {
            It "Exports $cmd" {
                $exported | Should -Contain $cmd
            }
        }
    }

    Context 'Wrapper delegations' {
        $maps = @(
            @{ Fn = 'Invoke-YFArchiveCleanup'; Target = 'Invoke-ArchiveCleanup'; Site = 'YF'; Url = 'https://contoso.sharepoint.com/sites/YF' },
            @{ Fn = 'Invoke-IBCCentralFilesArchiveCleanup'; Target = 'Invoke-ArchiveCleanup'; Site = 'IBCCentralFiles'; Url = 'https://contoso.sharepoint.com/sites/IBCCentralFiles' },
            @{ Fn = 'Invoke-MexCentralFilesArchiveCleanup'; Target = 'Invoke-ArchiveCleanup'; Site = 'MexCentralFiles'; Url = 'https://contoso.sharepoint.com/sites/MexCentralFiles' },
            @{ Fn = 'Invoke-YFFileVersionCleanup'; Target = 'Invoke-FileVersionCleanup'; Site = 'YF'; Url = 'https://contoso.sharepoint.com/sites/YF' },
            @{ Fn = 'Invoke-IBCCentralFilesFileVersionCleanup'; Target = 'Invoke-FileVersionCleanup'; Site = 'IBCCentralFiles'; Url = 'https://contoso.sharepoint.com/sites/IBCCentralFiles' },
            @{ Fn = 'Invoke-MexCentralFilesFileVersionCleanup'; Target = 'Invoke-FileVersionCleanup'; Site = 'MexCentralFiles'; Url = 'https://contoso.sharepoint.com/sites/MexCentralFiles' },
            @{ Fn = 'Invoke-YFSharingLinkCleanup'; Target = 'Invoke-SharingLinkCleanup'; Site = 'YF'; Url = 'https://contoso.sharepoint.com/sites/YF' },
            @{ Fn = 'Invoke-IBCCentralFilesSharingLinkCleanup'; Target = 'Invoke-SharingLinkCleanup'; Site = 'IBCCentralFiles'; Url = 'https://contoso.sharepoint.com/sites/IBCCentralFiles' },
            @{ Fn = 'Invoke-MexCentralFilesSharingLinkCleanup'; Target = 'Invoke-SharingLinkCleanup'; Site = 'MexCentralFiles'; Url = 'https://contoso.sharepoint.com/sites/MexCentralFiles' }
        )

        foreach ($m in $maps) {
            It "$($m.Fn) calls $($m.Target)" {
                Mock $m.Target {}
                & $m.Fn
                Assert-MockCalled $m.Target -ParameterFilter { $SiteName -eq $m.Site -and $SiteUrl -eq $m.Url } -Times 1
            }
        }
    }
}
