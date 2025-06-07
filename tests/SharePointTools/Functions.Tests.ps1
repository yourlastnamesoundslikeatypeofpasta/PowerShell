Describe 'SharePointTools functional commands' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/Logging/Logging.psd1 -Force
        Import-Module $PSScriptRoot/../../src/SharePointTools/SharePointTools.psd1 -Force
    }

    Context 'Get-SPToolsLibraryReport' {
        It 'returns library data' {
            InModuleScope SharePointTools {
                $SharePointToolsSettings = @{ Sites = @{ SiteA='https://contoso' } }
                function Connect-PnPOnline {}
                function Get-PnPList { $script:lists }
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Get-PnPList { $script:lists }
                Mock Disconnect-PnPOnline {}
                Mock Get-SPToolsSiteUrl { 'https://contoso' }
                $script:lists = @(
                    [pscustomobject]@{ Title='Docs'; ItemCount=1; LastItemUserModifiedDate=[datetime]'2024-01-01'; BaseTemplate=101 },
                    [pscustomobject]@{ Title='Records'; ItemCount=2; LastItemUserModifiedDate=[datetime]'2024-02-01'; BaseTemplate=101 }
                )
                $result = Get-SPToolsLibraryReport -SiteName 'SiteA'
                $result.Count | Should -Be 2
                $result[0].LibraryName | Should -Be 'Docs'
                Assert-MockCalled Connect-PnPOnline -Times 1
                Assert-MockCalled Disconnect-PnPOnline -Times 1
            }
        }
    }

    Context 'Get-SPToolsRecycleBinReport' {
        It 'reports item count and total size' {
            InModuleScope SharePointTools {
                $SharePointToolsSettings = @{ Sites = @{ SiteA='https://contoso' } }
                function Connect-PnPOnline {}
                function Get-PnPRecycleBinItem { $script:items }
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Get-PnPRecycleBinItem { $script:items }
                Mock Disconnect-PnPOnline {}
                Mock Get-SPToolsSiteUrl { 'https://contoso' }
                $script:items = @(
                    [pscustomobject]@{ Size = 1MB },
                    [pscustomobject]@{ Size = 2MB }
                )
                $r = Get-SPToolsRecycleBinReport -SiteName 'SiteA'
                $r.ItemCount | Should -Be 2
                $r.TotalSizeMB | Should -Be 3
            }
        }
    }

    Context 'Clear-SPToolsRecycleBin' {
        It 'clears first stage by default' {
            InModuleScope SharePointTools {
                $SharePointToolsSettings = @{ Sites = @{ SiteA='https://contoso' } }
                function Connect-PnPOnline {}
                function Clear-PnPRecycleBinItem {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Clear-PnPRecycleBinItem {}
                Mock Disconnect-PnPOnline {}
                Mock Get-SPToolsSiteUrl { 'https://contoso' }
                Clear-SPToolsRecycleBin -SiteName 'SiteA' -Confirm:$false
                Assert-MockCalled Clear-PnPRecycleBinItem -Times 1
            }
        }
        It 'clears second stage when requested' {
            InModuleScope SharePointTools {
                $SharePointToolsSettings = @{ Sites = @{ SiteA='https://contoso' } }
                function Connect-PnPOnline {}
                function Clear-PnPRecycleBinItem {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Clear-PnPRecycleBinItem {}
                Mock Disconnect-PnPOnline {}
                Mock Get-SPToolsSiteUrl { 'https://contoso' }
                Clear-SPToolsRecycleBin -SiteName 'SiteA' -SecondStage -Confirm:$false
                Assert-MockCalled Clear-PnPRecycleBinItem -Times 1
            }
        }
    }

    Context 'Get-SPToolsPreservationHoldReport' {
        It 'calculates file totals' {
            InModuleScope SharePointTools {
                $SharePointToolsSettings = @{ Sites = @{ SiteA='https://contoso' } }
                function Connect-PnPOnline {}
                function Get-PnPListItem { $script:items }
                function Get-PnPProperty {
                    param($obj,$prop)
                    if ($prop -eq 'File') { [pscustomobject]@{ Length = $obj.Size } }
                }
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Get-PnPListItem { $script:items }
                Mock Get-PnPProperty { param($obj,$prop) if ($prop -eq 'File') { [pscustomobject]@{ Length = $obj.Size } } }
                Mock Disconnect-PnPOnline {}
                Mock Get-SPToolsSiteUrl { 'https://contoso' }
                $script:items = @(
                    [pscustomobject]@{ Size = 1MB },
                    [pscustomobject]@{ Size = 3MB }
                )
                $report = Get-SPToolsPreservationHoldReport -SiteName 'SiteA'
                $report.ItemCount | Should -Be 2
                $report.TotalSizeMB | Should -Be 4
            }
        }
    }

    Context 'Clean-SPVersionHistory' {
        It 'deletes excess versions' {
            InModuleScope SharePointTools {
                $SharePointToolsSettings = @{ Sites = @{ SiteA='https://contoso' } }
                function Connect-PnPOnline {}
                function Get-PnPListItem { $script:items }
                function Get-PnPProperty { $script:versions }
                function Invoke-PnPQuery {}
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Get-PnPListItem { $script:items }
                Mock Get-PnPProperty { $script:versions }
                Mock Invoke-PnPQuery {}
                Mock Disconnect-PnPOnline {}
                $script:deleted = 0
                $script:items = @([pscustomobject]@{})
                $script:versions = @(
                    (New-Object PSObject -Property @{ Created=(Get-Date).AddDays(-3) }).psobject.BaseObject,
                    (New-Object PSObject -Property @{ Created=(Get-Date).AddDays(-2) }).psobject.BaseObject,
                    (New-Object PSObject -Property @{ Created=(Get-Date).AddDays(-1) }).psobject.BaseObject
                )
                foreach ($v in $script:versions) { $v | Add-Member -MemberType ScriptMethod -Name DeleteObject -Value { $script:deleted++ } }
                Clean-SPVersionHistory -SiteUrl 'https://contoso' -KeepVersions 1 -Confirm:$false
                $script:deleted | Should -Be 2
                Assert-MockCalled Invoke-PnPQuery -Times 1
            }
        }
    }

    Context 'Find-OrphanedSPFiles' {
        It 'returns files older than cutoff' {
            InModuleScope SharePointTools {
                $SharePointToolsSettings = @{ Sites = @{ SiteA='https://contoso' } }
                function Connect-PnPOnline {}
                function Get-PnPListItem { $script:items }
                function Get-PnPProperty { param($obj,$prop) $obj }
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Get-PnPListItem { $script:items }
                Mock Get-PnPProperty { param($obj,$prop) $obj }
                Mock Disconnect-PnPOnline {}
                $script:items = @(
                    [pscustomobject]@{ Name='old'; ServerRelativeUrl='/old'; TimeLastModified=(Get-Date).AddDays(-10) },
                    [pscustomobject]@{ Name='new'; ServerRelativeUrl='/new'; TimeLastModified=Get-Date }
                )
                $r = Find-OrphanedSPFiles -SiteUrl 'https://contoso' -Days 5
                $r.Count | Should -Be 1
                $r[0].Name | Should -Be 'old'
            }
        }
    }

    Context 'Get-SPPermissionsReport' {
        It 'reports role assignments' {
            InModuleScope SharePointTools {
                $SharePointToolsSettings = @{ Sites = @{ SiteA='https://contoso' } }
                function Connect-PnPOnline {}
                function Get-PnPSite { $null }
                function Get-PnPProperty {
                    param($obj,$prop)
                    switch ($prop) {
                        'RoleAssignments' { return @($script:assign) }
                        'Member' { return [pscustomobject]@{ Title='User'; PrincipalType='User' } }
                        'RoleDefinitionBindings' { return @([pscustomobject]@{ Name='Read' }) }
                    }
                }
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Get-PnPSite { $null }
                Mock Get-PnPProperty { param($obj,$prop) switch ($prop) {'RoleAssignments' { @($script:assign) } 'Member' { [pscustomobject]@{ Title='User'; PrincipalType='User' } } 'RoleDefinitionBindings' { @([pscustomobject]@{ Name='Read' }) } } }
                Mock Disconnect-PnPOnline {}
                $script:assign = [pscustomobject]@{}
                $r = Get-SPPermissionsReport -SiteUrl 'https://contoso'
                $r.Count | Should -Be 1
                $r[0].Member | Should -Be 'User'
                $r[0].Roles | Should -Be 'Read'
            }
        }
    }

    Context 'List-OneDriveUsage' {
        It 'returns personal sites' {
            InModuleScope SharePointTools {
                function Connect-PnPOnline {}
                function Get-PnPTenantSite { $script:sites }
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Get-PnPTenantSite { $script:sites }
                Mock Disconnect-PnPOnline {}
                $script:sites = @(
                    [pscustomobject]@{ Template='SPSPERS'; Url='u'; Owner='o'; StorageUsageCurrent=1GB },
                    [pscustomobject]@{ Template='STS'; Url='x'; Owner='y'; StorageUsageCurrent=1GB }
                )
                $r = List-OneDriveUsage -AdminUrl 'https://admin.contoso.com'
                $r.Count | Should -Be 1
                $r[0].StorageGB | Should -Be 1
            }
        }
    }

    Context 'Get-SPToolsFileReport' {
        It 'returns file metadata objects' {
            InModuleScope SharePointTools {
                $SharePointToolsSettings = @{ Sites = @{ SiteA='https://contoso' } }
                function Connect-PnPOnline {}
                function Get-PnPListItem { $script:items }
                function Disconnect-PnPOnline {}
                Mock Connect-PnPOnline {}
                Mock Get-PnPListItem { $script:items }
                Mock Disconnect-PnPOnline {}
                Mock Get-SPToolsSiteUrl { 'https://contoso' }
                $script:items = @(
                    [pscustomobject]@{ FileSystemObjectType='File'; FieldValues=@{ 'FileLeafRef'='file.txt'; 'File_x0020_Type'='txt'; 'File_x0020_Size'=1; 'Created_x0020_Date'=(Get-Date); 'Last_x0020_Modified'=(Get-Date); 'Created_x0020_By'='a'; 'Modified_x0020_By'='b'; 'FileRef'='/f'; 'FileDirRef'='/'; 'UniqueId'='1'; 'ParentUniqueId'='0'; 'ID'=1; 'ContentTypeId'='c'; 'ComplianceAssetId'=''; '_VirusStatus'=''; '_RansomwareAnomalyMetaInfo'=''; '_IsCurrentVersion'=1; 'Created'=(Get-Date); 'Modified'=(Get-Date); '_UIVersionString'='1'; '_UIVersion'=1; 'GUID'='g'; 'SMLastModifiedDate'=(Get-Date); 'SMTotalFileStreamSize'=1; 'MigrationWizId'=''; 'MigrationWizIdVersion'=''; 'Order'=0; 'StreamHash'=''; 'DocConcurrencyNumber'=1 } }
                )
                $r = Get-SPToolsFileReport -SiteName 'SiteA' -PageSize 10
                $r.Count | Should -Be 1
                $r[0].FileName | Should -Be 'file.txt'
            }
        }
    }
}
