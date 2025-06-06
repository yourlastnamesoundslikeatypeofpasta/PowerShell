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
            'Invoke-MexCentralFilesSharingLinkCleanup',
            'Get-SPToolsSettings',
            'Get-SPToolsSiteUrl',
            'Add-SPToolsSite',
            'Set-SPToolsSite',
            'Remove-SPToolsSite',
            'Get-SPToolsLibraryReport',
            'Get-SPToolsAllLibraryReports',
            'Get-SPToolsRecycleBinReport',
            'Clear-SPToolsRecycleBin',
            'Get-SPToolsAllRecycleBinReports',
            'Get-SPToolsPreservationHoldReport',
            'Get-SPToolsAllPreservationHoldReports',
            'Get-SPPermissionsReport',
            'Clean-SPVersionHistory',
            'Find-OrphanedSPFiles',
            'List-OneDriveUsage'
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
            @{ Fn = 'Invoke-YFArchiveCleanup'; Target = 'Invoke-ArchiveCleanup'; Site = 'YF' },
            @{ Fn = 'Invoke-IBCCentralFilesArchiveCleanup'; Target = 'Invoke-ArchiveCleanup'; Site = 'IBCCentralFiles' },
            @{ Fn = 'Invoke-MexCentralFilesArchiveCleanup'; Target = 'Invoke-ArchiveCleanup'; Site = 'MexCentralFiles' },
            @{ Fn = 'Invoke-YFFileVersionCleanup'; Target = 'Invoke-FileVersionCleanup'; Site = 'YF' },
            @{ Fn = 'Invoke-IBCCentralFilesFileVersionCleanup'; Target = 'Invoke-FileVersionCleanup'; Site = 'IBCCentralFiles' },
            @{ Fn = 'Invoke-MexCentralFilesFileVersionCleanup'; Target = 'Invoke-FileVersionCleanup'; Site = 'MexCentralFiles' },
            @{ Fn = 'Invoke-YFSharingLinkCleanup'; Target = 'Invoke-SharingLinkCleanup'; Site = 'YF' },
            @{ Fn = 'Invoke-IBCCentralFilesSharingLinkCleanup'; Target = 'Invoke-SharingLinkCleanup'; Site = 'IBCCentralFiles' },
            @{ Fn = 'Invoke-MexCentralFilesSharingLinkCleanup'; Target = 'Invoke-SharingLinkCleanup'; Site = 'MexCentralFiles' }
        )

        foreach ($m in $maps) {
            It "$($m.Fn) calls $($m.Target)" {
                Mock $m.Target {}
                & $m.Fn
                Assert-MockCalled $m.Target -ParameterFilter { $SiteName -eq $m.Site } -Times 1
            }
        }
    }

    Context 'Library reporting wrapper' {
        It 'calls Get-SPToolsLibraryReport for each site' {
            $SharePointToolsSettings.Sites.Clear()
            $SharePointToolsSettings.Sites['SiteA'] = 'https://contoso.sharepoint.com/sites/a'
            $SharePointToolsSettings.Sites['SiteB'] = 'https://contoso.sharepoint.com/sites/b'
            Mock Get-SPToolsLibraryReport {}
            Get-SPToolsAllLibraryReports
            Assert-MockCalled Get-SPToolsLibraryReport -ParameterFilter { $SiteName -eq 'SiteA' } -Times 1
            Assert-MockCalled Get-SPToolsLibraryReport -ParameterFilter { $SiteName -eq 'SiteB' } -Times 1
        }
    }
    Context 'Recycle bin reporting wrapper' {
        It 'calls Get-SPToolsRecycleBinReport for each site' {
            $SharePointToolsSettings.Sites.Clear()
            $SharePointToolsSettings.Sites['SiteA'] = 'https://contoso.sharepoint.com/sites/a'
            $SharePointToolsSettings.Sites['SiteB'] = 'https://contoso.sharepoint.com/sites/b'
            Mock Get-SPToolsRecycleBinReport {}
            Get-SPToolsAllRecycleBinReports
            Assert-MockCalled Get-SPToolsRecycleBinReport -ParameterFilter { $SiteName -eq 'SiteA' } -Times 1
            Assert-MockCalled Get-SPToolsRecycleBinReport -ParameterFilter { $SiteName -eq 'SiteB' } -Times 1
        }
    }
    Context 'Preservation hold reporting wrapper' {
        It 'calls Get-SPToolsPreservationHoldReport for each site' {
            $SharePointToolsSettings.Sites.Clear()
            $SharePointToolsSettings.Sites['SiteA'] = 'https://contoso.sharepoint.com/sites/a'
            $SharePointToolsSettings.Sites['SiteB'] = 'https://contoso.sharepoint.com/sites/b'
            Mock Get-SPToolsPreservationHoldReport {}
            Get-SPToolsAllPreservationHoldReports
            Assert-MockCalled Get-SPToolsPreservationHoldReport -ParameterFilter { $SiteName -eq 'SiteA' } -Times 1
            Assert-MockCalled Get-SPToolsPreservationHoldReport -ParameterFilter { $SiteName -eq 'SiteB' } -Times 1
        }
    }
}
