# SharePoint cleanup helpers

# Load configuration values if available
$repoRoot = Split-Path -Path $PSScriptRoot -Parent | Split-Path -Parent
$coreModule = Join-Path $PSScriptRoot '..' | Join-Path -ChildPath 'STCore/STCore.psd1'
Import-Module $coreModule -ErrorAction SilentlyContinue
$settingsFile = Join-Path $repoRoot 'config/SharePointToolsSettings.psd1'
$SharePointToolsSettings = Get-STConfig -Path $settingsFile
if (-not $SharePointToolsSettings) { $SharePointToolsSettings = @{} }
if (-not $SharePointToolsSettings.ContainsKey('ClientId')) { $SharePointToolsSettings.ClientId = '' }
if (-not $SharePointToolsSettings.ContainsKey('TenantId')) { $SharePointToolsSettings.TenantId = '' }
if (-not $SharePointToolsSettings.ContainsKey('CertPath')) { $SharePointToolsSettings.CertPath = '' }
if (-not $SharePointToolsSettings.ContainsKey('Sites')) { $SharePointToolsSettings.Sites = @{} }

$loggingModule = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Logging/Logging.psd1'
Import-Module $loggingModule -ErrorAction SilentlyContinue
$telemetryModule = Join-Path -Path (Split-Path -Path $PSScriptRoot -Parent) -ChildPath 'Telemetry/Telemetry.psd1'
Import-Module $telemetryModule -ErrorAction SilentlyContinue

# Override configuration with environment variables when provided
if ($env:SPTOOLS_CLIENT_ID) { $SharePointToolsSettings.ClientId = $env:SPTOOLS_CLIENT_ID }
if ($env:SPTOOLS_TENANT_ID) { $SharePointToolsSettings.TenantId = $env:SPTOOLS_TENANT_ID }
if ($env:SPTOOLS_CERT_PATH) { $SharePointToolsSettings.CertPath = $env:SPTOOLS_CERT_PATH }

# Load required module once at module scope
try {
    Import-Module PnP.PowerShell -ErrorAction Stop
} catch {
    Write-STStatus 'PnP.PowerShell module not found. SharePoint functions may not work until it is installed.' -Level WARN
}

function Write-SPToolsHacker {
    <#
    .SYNOPSIS
        Writes a formatted status message to the log.
    .PARAMETER Message
        Text to log.
    .PARAMETER Level
        Severity level for the message.
    .EXAMPLE
        Write-SPToolsHacker -Message 'Done' -Level SUCCESS
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [ValidateSet('INFO','SUCCESS','ERROR','WARN','SUB','FINAL','FATAL')]
        [string]$Level = 'INFO',
        [hashtable]$Metadata
    )
    process {
        Write-STStatus -Message $Message -Level $Level -Log
        if ($Level -in @('SUCCESS','ERROR','WARN','FATAL')) {
            $meta = @{ tool = 'SharePointTools'; level = $Level }
            if ($Metadata) { foreach ($k in $Metadata.Keys) { $meta[$k] = $Metadata[$k] } }
            Write-STLog -Message $Message -Level $Level -Structured -Metadata $meta
        }

    }
}
function Send-SPToolsTelemetryEvent {
    [CmdletBinding()]
    param(
        [string]$Command,
        [string]$Result,
        [timespan]$Duration
    )
    try {
        Write-STTelemetryEvent -ScriptName $Command -Result $Result -Duration $Duration -Category "SharePointTools"
    } catch {}
}


function Connect-SPToolsOnline {
    <#
    .SYNOPSIS
        Establishes a PnP connection with retry logic.
    .DESCRIPTION
        Wraps Connect-PnPOnline to provide standardized logging and
        basic retry support for transient authentication issues.
    .PARAMETER Url
        The SharePoint site URL to connect to.
    .PARAMETER ClientId
        Azure AD application client ID.
    .PARAMETER TenantId
        Azure AD tenant ID.
    .PARAMETER CertPath
        Path to the authentication certificate file.
    .PARAMETER ClientSecret
        Client secret string for authentication.
    .PARAMETER DeviceLogin
        Use device login flow for authentication.
    .PARAMETER RetryCount
        Number of connection attempts before failing.
    #>
    [CmdletBinding(DefaultParameterSetName='Certificate')]
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory, ParameterSetName='Certificate')]
        [Parameter(Mandatory, ParameterSetName='Secret')]
        [string]$ClientId,
        [Parameter(Mandatory, ParameterSetName='Certificate')]
        [Parameter(Mandatory, ParameterSetName='Secret')]
        [string]$TenantId,
        [Parameter(Mandatory, ParameterSetName='Certificate')]
        [string]$CertPath,
        [Parameter(Mandatory, ParameterSetName='Secret')]
        [string]$ClientSecret,
        [Parameter(ParameterSetName='Device')][switch]$DeviceLogin,
        [int]$RetryCount = 3
    )

    if (-not $DeviceLogin -and (-not $ClientId -or -not $TenantId)) {
        throw 'ClientId and TenantId are required unless using -DeviceLogin'
    }

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    $attempt = 1
    while ($true) {
        try {
            Write-STStatus "Connecting to $Url (attempt $attempt)" -Level INFO
            switch ($PSCmdlet.ParameterSetName) {
                'Certificate' {
                    Connect-PnPOnline -Url $Url -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath -ErrorAction Stop
                }
                'Secret' {
                    Connect-PnPOnline -Url $Url -ClientId $ClientId -Tenant $TenantId -ClientSecret $ClientSecret -ErrorAction Stop
                }
                'Device' {
                    Connect-PnPOnline -Url $Url -DeviceLogin -ErrorAction Stop
                }
            }
            Write-STStatus 'PnP connection established' -Level SUCCESS
            break
        } catch {
            Write-STStatus "Connection failed: $($_.Exception.Message)" -Level WARN
            $result = 'Failure'
            if ($attempt -ge $RetryCount) {
                Write-STStatus 'All connection attempts failed.' -Level ERROR
                throw
            }
            Start-Sleep -Seconds 5
            $attempt++
        }
    }
    $sw.Stop()
    Send-SPToolsTelemetryEvent -Command 'Connect-SPToolsOnline' -Result $result -Duration $sw.Elapsed
}

function Invoke-SPPnPCommand {
    <#
    .SYNOPSIS
        Executes a PnP.PowerShell command with standardized error handling.
    .PARAMETER ScriptBlock
        The command to execute.
    .PARAMETER ErrorMessage
        Message logged when the command fails.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][scriptblock]$ScriptBlock,
        [string]$ErrorMessage = 'PnP command failed'
    )
    try {
        & $ScriptBlock
    } catch {
        Write-STStatus "${ErrorMessage}: $($_.Exception.Message)" -Level ERROR
        throw
    }
}

function Save-SPToolsSettings {
    <#
    .SYNOPSIS
        Persists SharePoint Tools configuration to disk.
    .EXAMPLE
        Save-SPToolsSettings
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()
    process {
        if ($PSCmdlet.ShouldProcess($settingsFile, 'Save configuration')) {
            Write-SPToolsHacker 'Saving configuration'
            $SharePointToolsSettings | Out-File -FilePath $settingsFile -Encoding utf8
            Write-SPToolsHacker 'Configuration saved' -Level SUCCESS -Metadata @{ Path = $settingsFile }
        }
    }
}

function Test-SPToolsPrereqs {
    <#
    .SYNOPSIS
        Validates required modules for SharePoint tools.
    .DESCRIPTION
        Checks that the PnP.PowerShell module is available. Use -Install to
        automatically install it from the PowerShell Gallery when missing.
    .PARAMETER Install
        If specified, missing modules are installed without prompting.
    #>
    [CmdletBinding()]
    param(
        [switch]$Install
    )
    process {
        if (-not (Get-Module -ListAvailable -Name 'PnP.PowerShell')) {
            Write-SPToolsHacker 'PnP.PowerShell module not found.' -Level WARN
            if ($Install) {
                try {
                    Install-Module -Name 'PnP.PowerShell' -Scope CurrentUser -Force -ErrorAction Stop
                    Write-SPToolsHacker 'Installed PnP.PowerShell' -Level SUCCESS
                } catch {
                    Write-SPToolsHacker "Failed to install PnP.PowerShell: $($_.Exception.Message)" -Level ERROR
                }
            } else {
                Write-SPToolsHacker "Run 'Test-SPToolsPrereqs -Install' to install." -Level SUB
            }
        } else {
            Write-SPToolsHacker 'PnP.PowerShell module present.' -Level SUCCESS
        }
    }
}

function Get-SPToolsSettings {
    <#
    .SYNOPSIS
        Retrieves the current SharePoint Tools settings.
    .EXAMPLE
        Get-SPToolsSettings
    #>
    [CmdletBinding()]
    param()
    process {
        Write-SPToolsHacker 'Retrieving settings'
        $SharePointToolsSettings
    }
}

function Get-SPToolsSiteUrl {
    <#
    .SYNOPSIS
        Gets the site URL mapped to a given name.
    .PARAMETER SiteName
        Friendly name of the site.
    .EXAMPLE
        Get-SPToolsSiteUrl -SiteName 'MySite'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ $SharePointToolsSettings.Sites.ContainsKey($_) })]
        [string]$SiteName
    )
    process {
        Write-SPToolsHacker "Looking up $SiteName"
        $url = $SharePointToolsSettings.Sites[$SiteName]
        if (-not $url) { throw "Site '$SiteName' not found in settings." }
        Write-SPToolsHacker "URL found: $url"
        $url
    }
}

function Add-SPToolsSite {
    <#
    .SYNOPSIS
        Adds a new SharePoint site entry to the settings file.
    .PARAMETER Name
        Key used to reference the site.
    .PARAMETER Url
        Full URL of the SharePoint site.
    .EXAMPLE
        Add-SPToolsSite -Name 'Contoso' -Url 'https://contoso.sharepoint.com'
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$Url
    )
    process {
        if ($PSCmdlet.ShouldProcess($Name, 'Add site')) {
            Write-SPToolsHacker "Adding site $Name" -Metadata @{ Site = $Name; Url = $Url }
            $SharePointToolsSettings.Sites[$Name] = $Url
            Save-SPToolsSettings
            Write-SPToolsHacker 'Site added' -Level SUCCESS -Metadata @{ Site = $Name; Url = $Url }
        }
    }
}

function Set-SPToolsSite {
    <#
    .SYNOPSIS
        Updates an existing SharePoint site entry.
    .PARAMETER Name
        Key used to reference the site.
    .PARAMETER Url
        New URL to set for the site.
    .EXAMPLE
        Set-SPToolsSite -Name 'Contoso' -Url 'https://contoso.sharepoint.com'
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$Name,
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$Url
    )
    process {
        if ($PSCmdlet.ShouldProcess($Name, 'Update site')) {
            Write-SPToolsHacker "Updating site $Name" -Metadata @{ Site = $Name; Url = $Url }
            $SharePointToolsSettings.Sites[$Name] = $Url
            Save-SPToolsSettings
            Write-SPToolsHacker 'Site updated' -Level SUCCESS -Metadata @{ Site = $Name; Url = $Url }
        }
    }
}

function Remove-SPToolsSite {
    <#
    .SYNOPSIS
        Removes a SharePoint site entry from the settings file.
    .PARAMETER Name
        Key of the site to remove.
    .EXAMPLE
        Remove-SPToolsSite -Name 'Contoso'
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$Name
    )
    process {
        if ($PSCmdlet.ShouldProcess($Name, 'Remove site')) {
            Write-SPToolsHacker "Removing site $Name" -Metadata @{ Site = $Name }
            [void]$SharePointToolsSettings.Sites.Remove($Name)
            Save-SPToolsSettings
            Write-SPToolsHacker 'Site removed' -Level SUCCESS -Metadata @{ Site = $Name }
        }
    }
}


function Invoke-YFArchiveCleanup {
    <#
    .SYNOPSIS
        Removes archive items from the YF site.
    .EXAMPLE
        Invoke-YFArchiveCleanup
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Invoke-ArchiveCleanup -SiteName 'YF'
}

function Invoke-IBCCentralFilesArchiveCleanup {
    <#
    .SYNOPSIS
        Removes archive items from the IBCCentralFiles site.
    .EXAMPLE
        Invoke-IBCCentralFilesArchiveCleanup
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Invoke-ArchiveCleanup -SiteName 'IBCCentralFiles'
}

function Invoke-MexCentralFilesArchiveCleanup {
    <#
    .SYNOPSIS
        Removes archive items from the MexCentralFiles site.
    .EXAMPLE
        Invoke-MexCentralFilesArchiveCleanup
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Invoke-ArchiveCleanup -SiteName 'MexCentralFiles'
}

<#
.SYNOPSIS
  Removes archive folders and files from a SharePoint library.
.DESCRIPTION
  Connects using PnP.PowerShell and deletes items matching zzz_Archive.
.EXAMPLE
    Invoke-ArchiveCleanup -SiteName 'Finance'
#>
function Invoke-ArchiveCleanup {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath,
        [string]$TranscriptPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    if (-not $TranscriptPath) {
        $TranscriptPath = "$env:USERPROFILE/SHAREPOINT_CLEANUP_${SiteName}_$(Get-Date -Format yyyyMMdd_HHmmss).log"
    }
    Start-Transcript -Path $TranscriptPath -Append

    Write-STStatus "[+] Scanning target: $SiteName" -Level INFO
    $items = Invoke-SPPnPCommand { Get-PnPListItem -List $LibraryName -PageSize 5000 } 'Failed to retrieve list items'

    $files   = $items | Where-Object { $_.FileSystemObjectType -eq 'File' }
    $folders = $items | Where-Object { $_.FileSystemObjectType -eq 'Folder' }

    $archivedFiles = $files | Where-Object { $_.FieldValues.FileRef -match 'zzz_Archive' }
    $archivedFolders = $folders | Where-Object { $_.FieldValues.FileRef -match 'zzz_Archive' }

    $filesDeleted = 0
    $foldersDeleted = 0

    Write-STStatus "[>] Located $($archivedFiles.Count) archived files marked for deletion." -Level INFO
    if ($PSCmdlet.ShouldProcess($SiteName, 'Remove archived files and folders')) {
        foreach ($file in $archivedFiles) {
            $filePath = $file.FieldValues.FileRef
            try {
                Write-STStatus "-- Deleting file: $filePath" -Level SUB
                Remove-PnPFile -ServerRelativeUrl $filePath -Force -ErrorAction Stop
                $filesDeleted++
            } catch {
                Write-STStatus "[!] FILE DELETE FAIL: $filePath :: $_" -Level WARN
            }
        }

    $archivedFoldersSorted = $archivedFolders | Sort-Object {
        ($_.FieldValues.FileRef -split '/').Count
    } -Descending

    Write-STStatus "[>] Initiating folder cleanup (leaf-first)" -Level INFO
    foreach ($folder in $archivedFoldersSorted) {
        $folderPath = $folder.FieldValues.FileDirRef
        $folderName = $folder.FieldValues.FileLeafRef
        $fullPath = "$folderPath/$folderName"

        $relativePath = $fullPath -replace '^.*?Shared Documents/?', ''
        $folderDepth = ($relativePath -split '/').Count
        if ($folderDepth -le 1) {
            Write-STStatus "-- Skipping root-level folder: $fullPath" -Level WARN
            continue
        }

        try {
            Write-STStatus "-- Deleting folder: $fullPath" -Level SUB
            Remove-PnPFolder -Name $folderName -Folder $folderPath -Force -ErrorAction Stop
            $foldersDeleted++
        } catch {
            Write-STStatus "[!] FOLDER DELETE FAIL: $fullPath :: $_" -Level WARN
        }
    }

    }

    Stop-Transcript

    [pscustomobject]@{
        SiteName           = $SiteName
        ItemsScanned       = $items.Count
        ArchivedFilesFound = $archivedFiles.Count
        ArchivedFoldersFound = $archivedFolders.Count
        FilesDeleted       = $filesDeleted
        FoldersDeleted     = $foldersDeleted
        LogPath            = $TranscriptPath
    }
}

function Invoke-YFFileVersionCleanup {
    <#
    .SYNOPSIS
        Removes old file versions from the YF site.
    .EXAMPLE
        Invoke-YFFileVersionCleanup
    #>
    [CmdletBinding()]
    param()

    Invoke-FileVersionCleanup -SiteName 'YF'
}

function Invoke-IBCCentralFilesFileVersionCleanup {
    <#
    .SYNOPSIS
        Removes old file versions from the IBCCentralFiles site.
    .EXAMPLE
        Invoke-IBCCentralFilesFileVersionCleanup
    #>
    [CmdletBinding()]
    param()

    Invoke-FileVersionCleanup -SiteName 'IBCCentralFiles'
}

function Invoke-MexCentralFilesFileVersionCleanup {
    <#
    .SYNOPSIS
        Removes old file versions from the MexCentralFiles site.
    .EXAMPLE
        Invoke-MexCentralFilesFileVersionCleanup
    #>
    [CmdletBinding()]
    param()

    Invoke-FileVersionCleanup -SiteName 'MexCentralFiles'
}

<#
.SYNOPSIS
  Reports files with multiple versions.
.DESCRIPTION
  Generates a CSV of files with more than one version.
.EXAMPLE
    Invoke-FileVersionCleanup -SiteName 'Finance'
#>
function Invoke-FileVersionCleanup {
    [CmdletBinding()]
    param(
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath,
        [string]$ReportPath = 'exportedReport.csv'
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $rootFolder = Invoke-SPPnPCommand { Get-PnPFolder -ListRootFolder $LibraryName } 'Failed to get root folder'
    $subFolders = Invoke-SPPnPCommand { $rootFolder | Get-PnPFolderInFolder } 'Failed to enumerate folders'
    $targetFolder = $subFolders | Where-Object { $_.Name -eq 'Marketing' }

    Write-STStatus "Scanning target: $SiteName" -Level INFO
    $items = Invoke-SPPnPCommand { $targetFolder | Get-PnPFolderItem -Recursive -Verbose } 'Failed to list folder items'
    Write-STStatus "Located $($items.Count) files within $SiteUrl" -Level SUB

    $files = $items | Where-Object { $_.GetType().Name -eq 'File' }

    $report = foreach ($file in $files) {
        $versions = Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $file -Property Versions } 'Failed to get versions'
        if ($versions.Count -gt 1) {
            [pscustomobject]@{
                Name              = $file.Name
                Path              = $file.ServerRelativePath
                TotalVersionCount = $versions.Count
                TotalVersionBytes = [math]::Round((($versions.Size | Measure-Object -Sum).Sum) / 1GB, 8)
                TrueFileSize      = [math]::Round($file.Length / 1GB, 8)
            }
        }
    }

    $report | Export-Csv $ReportPath -NoTypeInformation
    Write-STStatus "Report exported to $ReportPath" -Level SUCCESS
}

<#
.SYNOPSIS
  Removes sharing links from a SharePoint library.
.DESCRIPTION
  Recursively scans a folder and deletes all file and folder sharing links.
.EXAMPLE
    Invoke-SharingLinkCleanup -SiteName 'Finance'
#>
function Invoke-SharingLinkCleanup {
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [string]$FolderName,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath,
        [string]$TranscriptPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    if (-not $TranscriptPath) {
        $TranscriptPath = "$env:USERPROFILE/SHAREPOINT_LINK_CLEANUP_${SiteName}_$(Get-Date -Format yyyyMMdd_HHmmss).log"
    }
    Start-Transcript -Path $TranscriptPath -Append

    if (-not $FolderName) {
        $targetFolder = Select-SPToolsFolder -SiteUrl $SiteUrl -LibraryName $LibraryName
    } else {
        $allFolders = Invoke-SPPnPCommand { Get-PnPFolderItem -List $LibraryName -ItemType Folder -Recursive } 'Failed to list folders'
        $targetFolder = $allFolders | Where-Object Name -eq $FolderName | Select-Object -First 1
        if (-not $targetFolder) { throw "Folder '$FolderName' not found." }
    }

    Write-STStatus "Scanning $($targetFolder.Name) for sharing links..." -Level INFO
    $items = Invoke-SPPnPCommand { $targetFolder | Get-PnPFolderItem -Recursive } 'Failed to list folder items'
    $removed = [System.Collections.Generic.List[string]]::new()

    if ($PSCmdlet.ShouldProcess($SiteName, 'Remove sharing links')) {
        foreach ($item in $items) {
            try {
                $link = (Get-PnPFileSharingLink -FileUrl $item.ServerRelativeUrl -ErrorAction Stop).Link.WebUrl
                if ($link) {
                    Remove-PnPFileSharingLink -FileUrl $item.ServerRelativeUrl -Force -ErrorAction SilentlyContinue
                    $removed.Add($item.ServerRelativeUrl)
                    Write-STStatus "Removed file link: $($item.ServerRelativeUrl)" -Level WARN
                }
            } catch {
                try {
                    $folderLink = (Get-PnPFolderSharingLink -Folder $item.ServerRelativeUrl -ErrorAction Stop).Link.WebUrl
                    if ($folderLink) {
                        Remove-PnPFolderSharingLink -Folder $item.ServerRelativeUrl -Force -ErrorAction SilentlyContinue
                        $removed.Add($item.ServerRelativeUrl)
                        Write-STStatus "Removed folder link: $($item.ServerRelativeUrl)" -Level WARN
                    }
                } catch {
                    # ignore if no links exist
                }
            }
        }
    }

    if ($removed.Count) {
        Write-STStatus 'Sharing links removed from the following items:' -Level WARN
        $removed | ForEach-Object { Write-STStatus $_ -Level WARN }
    } else {
        Write-STStatus 'No sharing links found.' -Level SUCCESS
    }

    Stop-Transcript
    Disconnect-PnPOnline
    Write-SPToolsHacker 'Recycle bin cleared'
}

function Invoke-YFSharingLinkCleanup {
    <#
    .SYNOPSIS
        Removes sharing links from the YF site.
    .EXAMPLE
        Invoke-YFSharingLinkCleanup
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Invoke-SharingLinkCleanup -SiteName 'YF'
}

function Invoke-IBCCentralFilesSharingLinkCleanup {
    <#
    .SYNOPSIS
        Removes sharing links from the IBCCentralFiles site.
    .EXAMPLE
        Invoke-IBCCentralFilesSharingLinkCleanup
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Invoke-SharingLinkCleanup -SiteName 'IBCCentralFiles'
}

function Invoke-MexCentralFilesSharingLinkCleanup {
    <#
    .SYNOPSIS
        Removes sharing links from the MexCentralFiles site.
    .EXAMPLE
        Invoke-MexCentralFilesSharingLinkCleanup
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param()

    Invoke-SharingLinkCleanup -SiteName 'MexCentralFiles'
}


function Get-SPToolsLibraryReport {
    <#
    .SYNOPSIS
        Generates a report of document libraries for a site.
    .PARAMETER SiteName
        Friendly site name configured in settings.
    .PARAMETER SiteUrl
        Full URL of the site. If omitted the URL from settings is used.
    .EXAMPLE
        Get-SPToolsLibraryReport -SiteName 'Finance'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker "Library report: $SiteName"

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $lists = Invoke-SPPnPCommand { Get-PnPList } 'Failed to retrieve lists' | Where-Object { $_.BaseTemplate -eq 101 }
    $report = foreach ($list in $lists) {
        [pscustomobject]@{
            SiteName     = $SiteName
            LibraryName  = $list.Title
            ItemCount    = $list.ItemCount
            LastModified = $list.LastItemUserModifiedDate
        }
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker 'Report complete'
    $report
}

function Get-SPToolsAllLibraryReports {
    <#
    .SYNOPSIS
        Generates library reports for all configured sites.
    .EXAMPLE
        Get-SPToolsAllLibraryReports
    #>
    [CmdletBinding()]
    param()

    Write-SPToolsHacker 'Generating all library reports'

    foreach ($entry in $SharePointToolsSettings.Sites.GetEnumerator()) {
        Get-SPToolsLibraryReport -SiteName $entry.Key -SiteUrl $entry.Value
    }
    Write-SPToolsHacker 'Reports complete'
}

function Out-SPToolsLibraryReport {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [pscustomobject]$InputObject
    )
    process {
        $InputObject | Format-Table SiteName,LibraryName,ItemCount,LastModified
    }
}

function Get-SPToolsRecycleBinReport {
    <#
    .SYNOPSIS
        Creates a recycle bin usage report for a site.
    .PARAMETER SiteName
        Friendly site name.
    .EXAMPLE
        Get-SPToolsRecycleBinReport -SiteName 'Finance'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker "Recycle bin report: $SiteName"

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $items = Invoke-SPPnPCommand { Get-PnPRecycleBinItem } 'Failed to retrieve recycle bin items'
    $totalSize = ($items | Measure-Object -Property Size -Sum).Sum
    $report = [pscustomobject]@{
        SiteName    = $SiteName
        ItemCount   = $items.Count
        TotalSizeMB = [math]::Round($totalSize / 1MB, 2)
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker 'Report complete'
    $report
}

function Clear-SPToolsRecycleBin {
    <#
    .SYNOPSIS
        Clears items from the SharePoint recycle bin.
    .PARAMETER SiteName
        Friendly site name.
    .EXAMPLE
        Clear-SPToolsRecycleBin -SiteName 'Finance' -SecondStage
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [switch]$SecondStage,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker "Clearing recycle bin: $SiteName"

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    if ($PSCmdlet.ShouldProcess($SiteName, 'Clear recycle bin')) {
        try {
            if ($SecondStage) {
                Clear-PnPRecycleBinItem -SecondStage -Force
            } else {
                Clear-PnPRecycleBinItem -FirstStage -Force
            }
            Write-STStatus 'Recycle bin cleared' -Level SUCCESS
        } catch {
            Write-STStatus "Failed to clear recycle bin: $($_.Exception.Message)" -Level ERROR
        }
    }

    Disconnect-PnPOnline
}

function Get-SPToolsAllRecycleBinReports {
    <#
    .SYNOPSIS
        Generates recycle bin reports for all configured sites.
    .EXAMPLE
        Get-SPToolsAllRecycleBinReports
    #>
    [CmdletBinding()]
    param()
    Write-SPToolsHacker 'Generating all recycle bin reports'
    foreach ($entry in $SharePointToolsSettings.Sites.GetEnumerator()) {
        Get-SPToolsRecycleBinReport -SiteName $entry.Key -SiteUrl $entry.Value
    }
    Write-SPToolsHacker 'Reports complete'
}

function Get-SPToolsPreservationHoldReport {
    <#
    .SYNOPSIS
        Reports the size of the Preservation Hold Library.
    .NOTES
        Uses PnP.PowerShell commands. See https://pnp.github.io/powershell/ for details.
    .EXAMPLE
        Get-SPToolsPreservationHoldReport -SiteName 'Finance'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }
    Write-SPToolsHacker "Hold report: $SiteName"

    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $items = Invoke-SPPnPCommand { Get-PnPListItem -List 'Preservation Hold Library' -PageSize 2000 } 'Failed to retrieve hold items'
    $files = foreach ($item in $items) { Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $item -Property File } 'Failed to get file info' }
    $totalSize = ($files | Measure-Object -Property Length -Sum).Sum
    $report = [pscustomobject]@{
        SiteName    = $SiteName
        ItemCount   = $files.Count
        TotalSizeMB = [math]::Round($totalSize / 1MB, 2)
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker 'Report complete'
    $report
}

function Get-SPToolsAllPreservationHoldReports {
    <#
    .SYNOPSIS
        Generates Preservation Hold Library reports for all sites.
    .EXAMPLE
        Get-SPToolsAllPreservationHoldReports
    #>
    [CmdletBinding()]
    param()
    Write-SPToolsHacker 'Generating all hold reports'
    foreach ($entry in $SharePointToolsSettings.Sites.GetEnumerator()) {
        Get-SPToolsPreservationHoldReport -SiteName $entry.Key -SiteUrl $entry.Value
    }
    Write-SPToolsHacker 'Reports complete'
}
function Get-SPPermissionsReport {
    <#
    .SYNOPSIS
        Retrieves permission assignments for a site or folder.
    .PARAMETER SiteUrl
        Full site URL.
    .PARAMETER FolderUrl
        Optional folder URL to limit the report.
    .EXAMPLE
        Get-SPPermissionsReport -SiteUrl 'https://contoso.sharepoint.com'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [string]$FolderUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker "Permissions report: $SiteUrl"
    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    if ($FolderUrl) {
        $target = Invoke-SPPnPCommand { Get-PnPFolder -Url $FolderUrl } 'Failed to get folder'
    } else {
        $target = Invoke-SPPnPCommand { Get-PnPSite } 'Failed to get site'
    }

    $assignments = Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $target -Property RoleAssignments } 'Failed to get role assignments'
    $report = foreach ($assignment in $assignments) {
        $member = Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $assignment -Property Member } 'Failed to get member'
        $roles = Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $assignment -Property RoleDefinitionBindings } 'Failed to get roles' | ForEach-Object { $_.Name } -join ','
        [pscustomobject]@{
            Member = $member.Title
            Type   = $member.PrincipalType
            Roles  = $roles
        }
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker 'Report complete'
    $report
}

function Clean-SPVersionHistory {
    <#
    .SYNOPSIS
        Deletes old document versions from a library.
    .EXAMPLE
        Clean-SPVersionHistory -SiteUrl 'https://contoso.sharepoint.com'
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [ValidateRange(1, [int]::MaxValue)]
        [int]$KeepVersions = 5,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker "Cleaning versions on $SiteUrl"
    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $items = Invoke-SPPnPCommand { Get-PnPListItem -List $LibraryName -PageSize 2000 } 'Failed to retrieve list items'
    if ($PSCmdlet.ShouldProcess($SiteUrl, 'Clean version history')) {
        foreach ($item in $items) {
            $versions = Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $item -Property Versions } 'Failed to get versions'
            if ($versions.Count -gt $KeepVersions) {
                $excess = $versions | Sort-Object -Property Created -Descending | Select-Object -Skip $KeepVersions
                foreach ($v in $excess) { $v.DeleteObject() | Out-Null }
                Invoke-SPPnPCommand { Invoke-PnPQuery } 'Failed to execute query'
            }
        }
    }
    Disconnect-PnPOnline
    Write-SPToolsHacker 'Cleanup complete'
}

function Find-OrphanedSPFiles {
    <#
    .SYNOPSIS
        Finds files not modified within a given number of days.
    .EXAMPLE
        Find-OrphanedSPFiles -SiteUrl 'https://contoso.sharepoint.com' -Days 30
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [ValidateRange(1, [int]::MaxValue)]
        [int]$Days = 90,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker "Searching orphaned files on $SiteUrl"
    Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $cutoff = (Get-Date).AddDays(-$Days)
    $items = Invoke-SPPnPCommand { Get-PnPListItem -List $LibraryName -PageSize 2000 } 'Failed to retrieve list items'
    $report = foreach ($item in $items) {
        $file = Invoke-SPPnPCommand { Get-PnPProperty -ClientObject $item -Property File } 'Failed to get file properties'
        if ($file.TimeLastModified -lt $cutoff) {
            [pscustomobject]@{
                Name         = $file.Name
                Path         = $file.ServerRelativeUrl
                LastModified = $file.TimeLastModified
            }
        }
    }
    Disconnect-PnPOnline
    Write-SPToolsHacker 'Search complete'
    $report
}

function Select-SPToolsFolder {
    <#
    .SYNOPSIS
        Interactively choose a folder from a document library.
    .DESCRIPTION
        Recursively enumerates folders and prompts for a selection. A filter
        string can be provided to narrow results.
    .EXAMPLE
        Select-SPToolsFolder -SiteName 'Finance'
    #>
    [CmdletBinding()]
    param(
        [ValidatePattern('^[A-Za-z0-9_-]+$')]
        [string]$SiteName,
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$SiteUrl,
        [ValidateNotNullOrEmpty()]
        [string]$LibraryName = 'Shared Documents',
        [string]$Filter,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    if (-not $SiteUrl) { $SiteUrl = Get-SPToolsSiteUrl -SiteName $SiteName }

    $conn = Get-PnPConnection -ErrorAction SilentlyContinue
    if (-not $conn) {
        Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath
        $needsDisconnect = $true
    }

    $list  = Invoke-SPPnPCommand { Get-PnPList -Identity $LibraryName -ErrorAction Stop } 'Failed to retrieve list'
    $items = Invoke-SPPnPCommand { Get-PnPFolderItem -List $list -ItemType Folder -Recursive } 'Failed to list folders'
    $rootPath = $list.RootFolder.ServerRelativeUrl

    $folders = foreach ($item in $items) {
        $relative = $item.ServerRelativeUrl.Substring($rootPath.Length).TrimStart('/')
        [pscustomobject]@{ Path = $relative; Object = $item }
    }

    if ($Filter) { $folders = $folders | Where-Object { $_.Path -like "*$Filter*" } }
    if (-not $folders) { throw 'No folders found.' }

    $map = @{}
    $i = 0
    foreach ($f in $folders) {
        Write-STStatus "$i - $($f.Path)" -Level INFO
        $map[$i] = $f.Object
        $i++
    }

    do {
        $choice = Read-Host -Prompt 'Select folder number'
    } until ($map.ContainsKey([int]$choice))

    if ($needsDisconnect) { Disconnect-PnPOnline }

    $map[[int]$choice]
}

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
function List-OneDriveUsage {
    <#
    .SYNOPSIS
        Lists usage information for all OneDrive sites.
    .EXAMPLE
        List-OneDriveUsage -AdminUrl 'https://contoso-admin.sharepoint.com'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateScript({ $_ -match '^https?://' })]
        [string]$AdminUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    Write-SPToolsHacker 'Gathering OneDrive usage'
    Connect-SPToolsOnline -Url $AdminUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath

    $sites = Invoke-SPPnPCommand { Get-PnPTenantSite -IncludeOneDriveSites } 'Failed to retrieve tenant sites'
    $report = foreach ($s in $sites) {
        if ($s.Template -eq 'SPSPERS') {
            [pscustomobject]@{
                Url       = $s.Url
                Owner     = $s.Owner
                StorageGB = [math]::Round($s.StorageUsageCurrent / 1GB, 2)
            }
        }
    }

    Disconnect-PnPOnline
    Write-SPToolsHacker 'Report complete'
    $report
}
Export-ModuleMember -Function 'Invoke-YFArchiveCleanup','Invoke-IBCCentralFilesArchiveCleanup','Invoke-MexCentralFilesArchiveCleanup','Invoke-ArchiveCleanup','Invoke-YFFileVersionCleanup','Invoke-IBCCentralFilesFileVersionCleanup','Invoke-MexCentralFilesFileVersionCleanup','Invoke-FileVersionCleanup','Invoke-SharingLinkCleanup','Invoke-YFSharingLinkCleanup','Invoke-IBCCentralFilesSharingLinkCleanup','Invoke-MexCentralFilesSharingLinkCleanup','Get-SPToolsSettings','Get-SPToolsSiteUrl','Add-SPToolsSite','Set-SPToolsSite','Remove-SPToolsSite','Get-SPToolsLibraryReport','Get-SPToolsAllLibraryReports','Out-SPToolsLibraryReport','Get-SPToolsRecycleBinReport','Clear-SPToolsRecycleBin','Get-SPToolsAllRecycleBinReports','Get-SPToolsFileReport','Get-SPToolsPreservationHoldReport','Get-SPToolsAllPreservationHoldReports','Get-SPPermissionsReport','Clean-SPVersionHistory','Find-OrphanedSPFiles','Select-SPToolsFolder','List-OneDriveUsage','Test-SPToolsPrereqs' -Variable 'SharePointToolsSettings'

function Register-SPToolsCompleters {
    <#
    .SYNOPSIS
        Registers tab completion for site names.
    .EXAMPLE
        Register-SPToolsCompleters
    #>
    $siteCmds = 'Get-SPToolsSiteUrl','Get-SPToolsLibraryReport','Get-SPToolsRecycleBinReport','Clear-SPToolsRecycleBin','Get-SPToolsPreservationHoldReport','Get-SPToolsAllLibraryReports','Get-SPToolsAllRecycleBinReports','Get-SPToolsFileReport','Select-SPToolsFolder'
    Register-ArgumentCompleter -CommandName $siteCmds -ParameterName SiteName -ScriptBlock {
        param($commandName,$parameterName,$wordToComplete)
        $SharePointToolsSettings.Sites.Keys | Where-Object { $_ -like "$wordToComplete*" } |
            ForEach-Object { [System.Management.Automation.CompletionResult]::new($_,$_, 'ParameterValue', $_) }
    }
    $nameCmds = 'Set-SPToolsSite','Remove-SPToolsSite','Add-SPToolsSite'
    Register-ArgumentCompleter -CommandName $nameCmds -ParameterName Name -ScriptBlock {
        param($commandName,$parameterName,$wordToComplete)
        $SharePointToolsSettings.Sites.Keys | Where-Object { $_ -like "$wordToComplete*" } |
            ForEach-Object { [System.Management.Automation.CompletionResult]::new($_,$_, 'ParameterValue', $_) }
    }
}

function Show-SharePointToolsBanner {
    <#
    .SYNOPSIS
        Returns SharePointTools module metadata for banner display.
    .EXAMPLE
        Show-SharePointToolsBanner
    #>
    [CmdletBinding()]
    param()
    $manifestPath = Join-Path $PSScriptRoot 'SharePointTools.psd1'
    [pscustomobject]@{
        Module  = 'SharePointTools'
        Version = (Import-PowerShellDataFile $manifestPath).ModuleVersion
    }
}

Register-SPToolsCompleters
