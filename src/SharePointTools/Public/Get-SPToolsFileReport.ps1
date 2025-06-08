function Get-SPToolsFileReport {
    <#
    .SYNOPSIS
        Generates a detailed file inventory for a site.
    .PARAMETER SiteName
        Friendly site name.
    .EXAMPLE
        Get-SPToolsFileReport -SiteName 'Finance'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Documents',
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath,
        [string]$ReportPath,
        [ValidateRange(1, 10000)]
        [int]$PageSize = 5000
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker "File report: $SiteName"

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $items = Invoke-SPPnPCommand { Get-PnPListItem -List $LibraryName -PageSize $PageSize } 'Failed to retrieve list items'
    $files = $items | Where-Object { $_.FileSystemObjectType -eq 'File' }
    $report = [System.Collections.Generic.List[object]]::new()

    foreach ($file in $files) {
        try {
            $field = $file.FieldValues
            $obj = [pscustomobject]@{
                FileName             = $field['FileLeafRef']
                FileType             = $field['File_x0020_Type']
                FileSizeBytes        = [int64]$field['File_x0020_Size']
                CreatedDate          = [datetime]$field['Created_x0020_Date']
                LastModifiedDate     = [datetime]$field['Last_x0020_Modified']
                CreatedBy            = $field['Created_x0020_By']
                ModifiedBy           = $field['Modified_x0020_By']
                FilePath             = $field['FileRef']
                DirectoryPath        = $field['FileDirRef']
                UniqueId             = $field['UniqueId']
                ParentUniqueId       = $field['ParentUniqueId']
                SharePointItemId     = $field['ID']
                ContentTypeId        = $field['ContentTypeId']
                ComplianceAssetId    = $field['ComplianceAssetId']
                VirusScanStatus      = $field['_VirusStatus']
                RansomwareMetadata   = $field['_RansomwareAnomalyMetaInfo']
                IsCurrentVersion     = $field['_IsCurrentVersion']
                CreatedDisplayDate   = [datetime]$field['Created']
                ModifiedDisplayDate  = [datetime]$field['Modified']
                VersionString        = $field['_UIVersionString']
                VersionNumber        = $field['_UIVersion']
                DocGUID              = $field['GUID']
                LastScanDate         = [datetime]$field['SMLastModifiedDate']
                StorageStreamSize    = [int64]$field['SMTotalFileStreamSize']
                MigrationId          = $field['MigrationWizId']
                MigrationVersion     = $field['MigrationWizIdVersion']
                OrderIndex           = $field['Order']
                StreamHash           = $field['StreamHash']
                ConcurrencyNumber    = $field['DocConcurrencyNumber']
            }
            $report.Add($obj)
        }
        catch {
            Write-STStatus "Error processing file: $_" -Level WARN
        }
    }

    Disconnect-PnPOnline

    if ($ReportPath) {
        $report | Export-Csv $ReportPath -NoTypeInformation
        Write-SPToolsHacker "Report exported to $ReportPath" -Level SUCCESS
    }

    Write-SPToolsHacker 'File report complete'
    $report
}
