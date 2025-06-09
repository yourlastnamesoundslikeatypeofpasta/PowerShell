function Test-SPToolsSiteAdmin {
    <#
    .SYNOPSIS
        Checks site availability and admin privileges.
    .DESCRIPTION
        Sends a HEAD request to the provided SharePoint site URL and verifies
        that the current user is a site collection administrator.
    .PARAMETER SiteUrl
        Full URL of the SharePoint site.
    .PARAMETER ClientId
        Azure AD application client ID. Defaults to configuration.
    .PARAMETER TenantId
        Azure AD tenant ID. Defaults to configuration.
    .PARAMETER CertPath
        Path to the authentication certificate. Defaults to configuration.
    .EXAMPLE
        Test-SPToolsSiteAdmin -SiteUrl https://contoso.sharepoint.com/sites/hr
    #>
    [CmdletBinding()]
    [OutputType([pscustomobject])]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^https?://')]
        [string]$SiteUrl,
        [string]$ClientId = $SharePointToolsSettings.ClientId,
        [Alias('TenantID','tenantId')]
        [string]$TenantId = $SharePointToolsSettings.TenantId,
        [string]$CertPath = $SharePointToolsSettings.CertPath
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    Write-STLog -Message "Test-SPToolsSiteAdmin $SiteUrl"

    try {
        Write-STStatus 'Checking HTTP response' -Level INFO
        $resp = Invoke-WebRequest -Uri $SiteUrl -Method Head -UseBasicParsing -ErrorAction Stop
        $status = [int]$resp.StatusCode
        Write-STStatus "HTTP status: $status" -Level SUB
    } catch {
        $result = 'Failure'
        Write-STLog -Message "HTTP check failed: $_" -Level ERROR
        throw
    }

    $isAdmin = $false
    try {
        Connect-SPToolsOnline -Url $SiteUrl -ClientId $ClientId -TenantId $TenantId -CertPath $CertPath
        $info = Invoke-PnPSPRestMethod -Url '/_api/web/CurrentUser' -Method Get
        $isAdmin = [bool]$info.IsSiteAdmin
        Write-STStatus "Site admin: $isAdmin" -Level SUB
    } catch {
        $result = 'Failure'
        Write-STLog -Message "Admin rights check failed: $_" -Level ERROR
        throw
    } finally {
        Disconnect-PnPOnline -ErrorAction SilentlyContinue
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Test-SPToolsSiteAdmin' -Result $result -Duration $sw.Elapsed -Category 'SharePointTools'
        Write-STLog -Message 'Test-SPToolsSiteAdmin result' -Metadata @{ url = $SiteUrl; status = $status; isAdmin = $isAdmin }
    }

    [pscustomobject]@{
        Url        = $SiteUrl
        StatusCode = $status
        IsAdmin    = $isAdmin
    }
}
