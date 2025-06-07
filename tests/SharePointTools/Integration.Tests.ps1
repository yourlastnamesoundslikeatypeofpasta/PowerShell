Describe 'SharePointTools Integration Functions' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
    }

    Context 'Get-SPToolsLibraryReport' {
        It 'returns library information' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Get-PnPList {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Disconnect-PnPOnline {}
                Mock Get-PnPList { @([pscustomobject]@{ Title='Docs'; BaseTemplate=101; ItemCount=5; LastItemUserModifiedDate='2023-01-01' }) }
                $result = Get-SPToolsLibraryReport -SiteName 'A' -SiteUrl 'https://contoso'
                $result.LibraryName | Should -Be 'Docs'
                Assert-MockCalled Connect-PnPOnline -Times 1
                Assert-MockCalled Disconnect-PnPOnline -Times 1
            }
        }
    }

    Context 'Get-SPToolsRecycleBinReport' {
        It 'summarizes recycle bin usage' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Get-PnPRecycleBinItem {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Disconnect-PnPOnline {}
                Mock Get-PnPRecycleBinItem { @([pscustomobject]@{ Size = 2MB },[pscustomobject]@{ Size = 3MB }) }
                $r = Get-SPToolsRecycleBinReport -SiteName 'A' -SiteUrl 'https://c'
                $r.ItemCount | Should -Be 2
                $r.TotalSizeMB | Should -Be 5
                Assert-MockCalled Connect-PnPOnline -Times 1
            }
        }
    }


    Context 'Invoke-FileVersionCleanup' {
        It 'exports a CSV report' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Get-PnPFolder {}
                function Get-PnPFolderInFolder {}
                function Get-PnPFolderItem {}
                function Get-PnPProperty {}
                function Export-Csv {}
                Mock Connect-PnPOnline {}
                Mock Get-PnPFolder { 'root' }
                Mock Get-PnPFolderInFolder { @([pscustomobject]@{ Name='Marketing' }) }
                Mock Get-PnPFolderItem { @() }
                Mock Get-PnPProperty { @() }
                Mock Export-Csv {} -ModuleName SharePointTools
                Invoke-FileVersionCleanup -SiteName 'A' -SiteUrl 'https://c' -ReportPath 'r.csv'
                Assert-MockCalled Connect-PnPOnline -Times 1
                Assert-MockCalled Export-Csv -ModuleName SharePointTools -Times 1
            }
        }
    }

    Context 'Invoke-SharingLinkCleanup' {
        It 'removes sharing links from specified folder' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Get-PnPFolderItem {}
                function Get-PnPFileSharingLink {}
                function Remove-PnPFileSharingLink {}
                function Get-PnPFolderSharingLink {}
                function Remove-PnPFolderSharingLink {}
                function Start-Transcript {}
                function Stop-Transcript {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Get-PnPFolderItem { @([pscustomobject]@{ ServerRelativeUrl='/f'; Name='f' }) }
                Mock Get-PnPFileSharingLink { @{ Link = @{ WebUrl='u' } } }
                Mock Remove-PnPFileSharingLink {}
                Mock Get-PnPFolderSharingLink { }
                Mock Remove-PnPFolderSharingLink {}
                Mock Start-Transcript {}
                Mock Stop-Transcript {}
                Invoke-SharingLinkCleanup -SiteName 'A' -SiteUrl 'https://c' -FolderName 'f' -Confirm:$false
                Assert-MockCalled Remove-PnPFileSharingLink -Times 1
            }
        }
    }

    Context 'Clear-SPToolsRecycleBin' {
        It 'clears the first stage bin by default' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Clear-PnPRecycleBinItem {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Clear-PnPRecycleBinItem {} -ModuleName SharePointTools
                Mock Disconnect-PnPOnline {}
                Clear-SPToolsRecycleBin -SiteName 'A' -SiteUrl 'https://c' -Confirm:$false
                Assert-MockCalled Clear-PnPRecycleBinItem -ParameterFilter { $FirstStage -and -not $SecondStage } -Times 1
            }
        }
    }

    Context 'Get-SPToolsPreservationHoldReport' {
        It 'reports total hold size' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Get-PnPListItem {}
                function Get-PnPProperty {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Disconnect-PnPOnline {}
                Mock Get-PnPListItem { @(1,2) }
                Mock Get-PnPProperty { param($ClientObject,$Property) [pscustomobject]@{ Length = 1MB } }
                $r = Get-SPToolsPreservationHoldReport -SiteName 'A' -SiteUrl 'https://c'
                $r.ItemCount | Should -Be 2
                $r.TotalSizeMB | Should -Be 2
            }
        }
    }

    Context 'Get-SPPermissionsReport' {
        It 'returns permission assignments' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Get-PnPSite {}
                function Get-PnPProperty {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Disconnect-PnPOnline {}
                Mock Get-PnPSite { 'site' } -ModuleName SharePointTools
                Mock Get-PnPProperty { @() } -ModuleName SharePointTools
                Get-SPPermissionsReport -SiteUrl 'https://c'
                Assert-MockCalled Connect-PnPOnline -Times 1
            }
        }
    }

    Context 'Clean-SPVersionHistory' {
        It 'invokes version cleanup when versions exceed threshold' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Get-PnPListItem {}
                function Get-PnPProperty {}
                function Invoke-PnPQuery {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Disconnect-PnPOnline {}
                $ver = New-Object PSObject -Property @{ Created = (Get-Date) }
                $ver | Add-Member -MemberType ScriptMethod -Name DeleteObject -Value { $script:deleted = $true }
                Mock Get-PnPListItem { @( @{ } ) }
                Mock Get-PnPProperty { @( $ver,$ver,$ver,$ver,$ver,$ver ) }
                Mock Invoke-PnPQuery {}
                Clean-SPVersionHistory -SiteUrl 'https://c' -KeepVersions 3 -Confirm:$false
                Assert-MockCalled Invoke-PnPQuery -Times 1
            }
        }
    }

    Context 'Find-OrphanedSPFiles' {
        It 'returns files older than specified days' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Get-PnPListItem {}
                function Get-PnPProperty {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Disconnect-PnPOnline {}
                $file = [pscustomobject]@{ Name='f'; ServerRelativeUrl='/f'; TimeLastModified=(Get-Date).AddDays(-10) }
                Mock Get-PnPListItem { @( @{ } ) }
                Mock Get-PnPProperty { $file }
                $r = Find-OrphanedSPFiles -SiteUrl 'https://c' -Days 5
                $r.Name | Should -Be 'f'
                Assert-MockCalled Connect-PnPOnline -Times 1
            }
        }
    }

    Context 'Select-SPToolsFolder' {
        It 'returns chosen folder object' {
            InModuleScope SharePointTools {
                function Get-PnPConnection {}
                function Connect-PnPOnline {}
                function Get-PnPList {}
                function Get-PnPFolderItem {}
                function Disconnect-PnPOnline {}
                function Read-Host {}
                Mock Get-PnPConnection { $null }
                Mock Connect-PnPOnline {}
                Mock Disconnect-PnPOnline {}
                Mock Get-PnPList { [pscustomobject]@{ RootFolder = @{ ServerRelativeUrl='/root' } } }
                $folderObj = [pscustomobject]@{ ServerRelativeUrl='/root/sub' }
                Mock Get-PnPFolderItem { $folderObj }
                Mock Read-Host { '0' }
                $f = Select-SPToolsFolder -SiteUrl 'https://c'
                $f.ServerRelativeUrl | Should -Be '/root/sub'
            }
        }
    }

    Context 'Get-SPToolsFileReport' {
        It 'returns report entries for files' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Get-PnPListItem {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Disconnect-PnPOnline {}
                $item = [pscustomobject]@{ FileSystemObjectType='File'; FieldValues=@{ FileLeafRef='a.txt'; File_x0020_Size=1; Created_x0020_Date='2023-01-01'; Last_x0020_Modified='2023-01-02'; FileRef='/a.txt'; FileDirRef='/'; UniqueId='u'; ParentUniqueId='p'; ID=1; ContentTypeId='ct'; ComplianceAssetId='c'; _VirusStatus=''; _RansomwareAnomalyMetaInfo=''; _IsCurrentVersion=''; Created='2023-01-01'; Modified='2023-01-02'; _UIVersionString='1'; _UIVersion='1'; GUID='guid'; SMLastModifiedDate='2023-01-02'; SMTotalFileStreamSize=1; MigrationWizId='m'; MigrationWizIdVersion='v'; Order='1'; StreamHash='h'; DocConcurrencyNumber='1'; File_x0020_Type='txt' } }
                Mock Get-PnPListItem { @($item) }
                $r = Get-SPToolsFileReport -SiteName 'A' -SiteUrl 'https://c'
                $r[0].FileName | Should -Be 'a.txt'
            }
        }
    }

    Context 'List-OneDriveUsage' {
        It 'reports tenant site usage' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Get-PnPTenantSite {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Disconnect-PnPOnline {}
                $site = [pscustomobject]@{ Template='SPSPERS'; Url='https://u'; Owner='o'; StorageUsageCurrent=1GB }
                Mock Get-PnPTenantSite { @($site) }
                $r = List-OneDriveUsage -AdminUrl 'https://admin'
                $r[0].Url | Should -Be 'https://u'
                $r[0].StorageGB | Should -Be 1
            }
        }
    }

    Context 'Test-SPToolsPrereqs' {
        It 'installs module when missing and install flag used' {
            InModuleScope SharePointTools {
                function Install-Module {}
                Mock Get-Module { $null } -ModuleName SharePointTools
                Mock Install-Module {} -ModuleName SharePointTools
                Mock Write-SPToolsHacker {} -ModuleName SharePointTools
                Test-SPToolsPrereqs -Install
                Assert-MockCalled Install-Module -Times 1
            }
        }
    }
}
