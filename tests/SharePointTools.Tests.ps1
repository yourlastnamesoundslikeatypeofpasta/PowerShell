Describe 'SharePointTools Module' {
    BeforeAll {
        Import-Module $PSScriptRoot/../src/Logging/Logging.psd1 -Force
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
            'Find-OrphanedSPFiles','Get-SPToolsFileReport',
            'Select-SPToolsFolder','List-OneDriveUsage'
        )
        $exported = (Get-Command -Module SharePointTools).Name
        foreach ($cmd in $expected) {
            $c = $cmd
            It "Exports $c" {
                $exported | Should -Contain $c
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

        $cases = foreach ($m in $maps) {
            @{ Fn = $m.Fn; Target = $m.Target }
        }

        It '<Fn> calls <Target>' -ForEach $cases {
            Mock $Target {} -ModuleName SharePointTools
            & $Fn
            Assert-MockCalled $Target -ModuleName SharePointTools -Times 1
        }
    }

    Context 'Library reporting wrapper' {
        It 'calls Get-SPToolsLibraryReport for each site' {
            $SharePointToolsSettings.Sites.Clear()
            $SharePointToolsSettings.Sites['SiteA'] = 'https://contoso.sharepoint.com/sites/a'
            $SharePointToolsSettings.Sites['SiteB'] = 'https://contoso.sharepoint.com/sites/b'
            Mock Get-SPToolsLibraryReport {} -ModuleName SharePointTools
            Get-SPToolsAllLibraryReports
            Assert-MockCalled Get-SPToolsLibraryReport -ModuleName SharePointTools -ParameterFilter { $SiteName -eq 'SiteA' } -Times 1
            Assert-MockCalled Get-SPToolsLibraryReport -ModuleName SharePointTools -ParameterFilter { $SiteName -eq 'SiteB' } -Times 1
        }
    }
    Context 'Recycle bin reporting wrapper' {
        It 'calls Get-SPToolsRecycleBinReport for each site' {
            $SharePointToolsSettings.Sites.Clear()
            $SharePointToolsSettings.Sites['SiteA'] = 'https://contoso.sharepoint.com/sites/a'
            $SharePointToolsSettings.Sites['SiteB'] = 'https://contoso.sharepoint.com/sites/b'
            Mock Get-SPToolsRecycleBinReport {} -ModuleName SharePointTools
            Get-SPToolsAllRecycleBinReports
            Assert-MockCalled Get-SPToolsRecycleBinReport -ModuleName SharePointTools -ParameterFilter { $SiteName -eq 'SiteA' } -Times 1
            Assert-MockCalled Get-SPToolsRecycleBinReport -ModuleName SharePointTools -ParameterFilter { $SiteName -eq 'SiteB' } -Times 1
        }
    }
    Context 'Preservation hold reporting wrapper' {
        It 'calls Get-SPToolsPreservationHoldReport for each site' {
            $SharePointToolsSettings.Sites.Clear()
            $SharePointToolsSettings.Sites['SiteA'] = 'https://contoso.sharepoint.com/sites/a'
            $SharePointToolsSettings.Sites['SiteB'] = 'https://contoso.sharepoint.com/sites/b'
            Mock Get-SPToolsPreservationHoldReport {} -ModuleName SharePointTools
            Get-SPToolsAllPreservationHoldReports
            Assert-MockCalled Get-SPToolsPreservationHoldReport -ModuleName SharePointTools -ParameterFilter { $SiteName -eq 'SiteA' } -Times 1
            Assert-MockCalled Get-SPToolsPreservationHoldReport -ModuleName SharePointTools -ParameterFilter { $SiteName -eq 'SiteB' } -Times 1
        }
    }

    Context 'Site management functions' {
        BeforeEach {
            $script:tempCfg = [System.IO.Path]::GetTempFileName()
            InModuleScope SharePointTools {
                $SharePointToolsSettings = @{ ClientId=''; TenantId=''; CertPath=''; Sites=@{} }
                $script:settingsFile = $tempCfg
                Mock Write-SPToolsHacker {}
            }
        }
        AfterEach {
            Remove-Item $tempCfg -ErrorAction SilentlyContinue
        }

        It 'Add-SPToolsSite stores the URL and saves settings' {
            InModuleScope SharePointTools {
                Mock Save-SPToolsSettings {}
                Add-SPToolsSite -Name 'SiteA' -Url 'https://contoso.sharepoint.com/sites/a'
                $SharePointToolsSettings.Sites['SiteA'] | Should -Be 'https://contoso.sharepoint.com/sites/a'
                Assert-MockCalled Save-SPToolsSettings -Times 1
            }
        }

        It 'Set-SPToolsSite updates an existing entry' {
            InModuleScope SharePointTools {
                Mock Save-SPToolsSettings {}
                $SharePointToolsSettings.Sites['SiteA'] = 'https://old'
                Set-SPToolsSite -Name 'SiteA' -Url 'https://new'
                $SharePointToolsSettings.Sites['SiteA'] | Should -Be 'https://new'
                Assert-MockCalled Save-SPToolsSettings -Times 1
            }
        }

        It 'Remove-SPToolsSite deletes the entry' {
            InModuleScope SharePointTools {
                Mock Save-SPToolsSettings {}
                $SharePointToolsSettings.Sites['SiteA'] = 'https://contoso'
                Remove-SPToolsSite -Name 'SiteA'
                $SharePointToolsSettings.Sites.ContainsKey('SiteA') | Should -BeFalse
                Assert-MockCalled Save-SPToolsSettings -Times 1
            }
        }

        It 'Get-SPToolsSiteUrl returns the url and throws when missing' {
            InModuleScope SharePointTools {
                $SharePointToolsSettings.Sites['SiteA'] = 'https://contoso'
                Get-SPToolsSiteUrl -SiteName 'SiteA' | Should -Be 'https://contoso'
                { Get-SPToolsSiteUrl -SiteName 'Missing' } | Should -Throw
            }
        }

        It 'Get-SPToolsSettings returns the current settings object' {
            InModuleScope SharePointTools {
                $SharePointToolsSettings.Sites['SiteA'] = 'https://contoso'
                (Get-SPToolsSettings).Sites['SiteA'] | Should -Be 'https://contoso'
            }
        }
    }
}
