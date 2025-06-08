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
    .PARAMETER RetryCount
        Number of connection attempts before failing.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$Url,
        [Parameter(Mandatory)][string]$ClientId,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$CertPath,
        [int]$RetryCount = 3
    )
    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = "Success"
    $attempt = 1
    while ($true) {
        try {
            Write-STStatus "Connecting to $Url (attempt $attempt)" -Level INFO
            Connect-PnPOnline -Url $Url -ClientId $ClientId -Tenant $TenantId -CertificatePath $CertPath -ErrorAction Stop
            Write-STStatus 'PnP connection established' -Level SUCCESS
            break
        } catch {
            Write-STStatus "Connection failed: $($_.Exception.Message)" -Level WARN
                $result = "Failure"
            if ($attempt -ge $RetryCount) {
                Write-STStatus 'All connection attempts failed.' -Level ERROR
                throw
            }
            Start-Sleep -Seconds 5
            $attempt++
        }
    $sw.Stop()
    Send-SPToolsTelemetryEvent -Command "Connect-SPToolsOnline" -Result $result -Duration $sw.Elapsed
    }
}

