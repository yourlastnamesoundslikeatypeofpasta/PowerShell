. $PSScriptRoot/../TestHelpers.ps1
Describe 'SharePointTools Integration Functions' {
    Initialize-TestDrive
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
        InModuleScope SharePointTools {
            $SharePointToolsSettings.ClientId  = 'id'
            $SharePointToolsSettings.TenantId  = 'tid'
            $SharePointToolsSettings.CertPath  = 'cert.pfx'
        }
    }

    BeforeEach {
        InModuleScope SharePointTools {
            Set-Variable -Scope Script -Name SharePointToolsSettings -Value @{ ClientId='id'; TenantId='tid'; CertPath='path'; Sites=@{} }
        }
    }

    Context 'Get-SPToolsLibraryReport' {
        Safe-It 'returns library information' {
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
        Safe-It 'summarizes recycle bin usage' {
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
        Safe-It 'exports a CSV report' {
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
                $file = New-Object PSObject -Property @{ ServerRelativePath='/f'; Name='f'; Length=1 }
                $file | Add-Member -MemberType ScriptMethod -Name GetType -Value { @{ Name='File' } } -Force
                Mock Get-PnPFolderItem { @($file) }
                Mock Get-PnPProperty { @(1,2) }
                Mock Export-Csv {} -ModuleName SharePointTools
                Invoke-FileVersionCleanup -SiteName 'A' -SiteUrl 'https://c' -ReportPath 'r.csv'
                Assert-MockCalled Connect-PnPOnline -Times 1
                Assert-MockCalled Export-Csv -ModuleName SharePointTools -Times 1
            }
        }
        Safe-It 'suppresses telemetry with NoTelemetry' {
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
                $file = New-Object PSObject -Property @{ ServerRelativePath='/f'; Name='f'; Length=1 }
                $file | Add-Member -MemberType ScriptMethod -Name GetType -Value { @{ Name='File' } } -Force
                Mock Get-PnPFolderItem { @($file) }
                Mock Get-PnPProperty { @(1,2) }
                Mock Export-Csv {} -ModuleName SharePointTools
                Mock Write-STTelemetryEvent {} -ModuleName SharePointTools
                Invoke-FileVersionCleanup -SiteName 'A' -SiteUrl 'https://c' -ReportPath 'r.csv' -NoTelemetry
                Assert-MockCalled Write-STTelemetryEvent -ModuleName SharePointTools -Times 0
            }
        }
    }

    Context 'Invoke-SharingLinkCleanup' {
        Safe-It 'removes sharing links from specified folder' {
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
        Safe-It 'suppresses telemetry with NoTelemetry' {
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
                Mock Get-PnPFolderSharingLink {}
                Mock Remove-PnPFolderSharingLink {}
                Mock Start-Transcript {}
                Mock Stop-Transcript {}
                Mock Write-STTelemetryEvent {} -ModuleName SharePointTools
                Invoke-SharingLinkCleanup -SiteName 'A' -SiteUrl 'https://c' -FolderName 'f' -NoTelemetry -Confirm:$false
                Assert-MockCalled Write-STTelemetryEvent -ModuleName SharePointTools -Times 0
            }
        }
    }

    Context 'Clear-SPToolsRecycleBin' {
        Safe-It 'clears the first stage bin by default' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Clear-PnPRecycleBinItem { param([switch]$FirstStage,[switch]$SecondStage,[switch]$Force) }
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
        Safe-It 'reports total hold size' {
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
        Safe-It 'returns expected fields' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Get-PnPListItem {}
                function Get-PnPProperty {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Disconnect-PnPOnline {}
                Mock Get-PnPListItem { @(1) }
                Mock Get-PnPProperty { param($ClientObject,$Property) [pscustomobject]@{ Length = 1MB } }
                $result = Get-SPToolsPreservationHoldReport -SiteName 'A' -SiteUrl 'https://c'
                $props = $result.PSObject.Properties.Name
                $props | Should -Contain 'SiteName'
                $props | Should -Contain 'ItemCount'
                $props | Should -Contain 'TotalSizeMB'
            }
        }
    }

    Context 'Get-SPPermissionsReport' {
        Safe-It 'returns permission assignments' {
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
        Safe-It 'invokes version cleanup when versions exceed threshold' {
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
        Safe-It 'returns files older than specified days' {
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
        Safe-It 'returns chosen folder object' {
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
        Safe-It 'returns report entries for files' {
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
        Safe-It 'reports tenant site usage' {
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

    Context 'Invoke-SPSiteAudit' {
        Safe-It 'aggregates site reports' {
            InModuleScope SharePointTools {
                function Get-SPToolsLibraryReport {}
                function Get-SPToolsRecycleBinReport {}
                function Get-SPToolsPreservationHoldReport {}
                Mock Get-SPToolsLibraryReport { 'lib' }
                Mock Get-SPToolsRecycleBinReport { 'rec' }
                Mock Get-SPToolsPreservationHoldReport { 'hold' }
                $s = Invoke-SPSiteAudit -SiteName 'A' -SiteUrl 'https://c'
                $s.LibraryReport | Should -Be 'lib'
                $s.RecycleBinReport | Should -Be 'rec'
                $s.PreservationHoldReport | Should -Be 'hold'
                Assert-MockCalled Get-SPToolsLibraryReport -Times 1
                Assert-MockCalled Get-SPToolsRecycleBinReport -Times 1
                Assert-MockCalled Get-SPToolsPreservationHoldReport -Times 1
            }
        }
    }

    Context 'Test-SPToolsPrereqs' {
        Safe-It 'installs module when missing and install flag used' {
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
