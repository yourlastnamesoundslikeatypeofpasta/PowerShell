function Disable-GraphUser {
    <#
    .SYNOPSIS
        Disables a user account via Microsoft Graph or Active Directory.
    .DESCRIPTION
        Sets accountEnabled to false using Microsoft Graph or disables the AD account when Cloud is AD.
    .PARAMETER UserPrincipalName
        UPN of the user to disable.
    .PARAMETER TenantId
        Azure AD tenant ID for Graph authentication.
    .PARAMETER ClientId
        Application (client) ID for Graph authentication.
    .PARAMETER ClientSecret
        Optional client secret for the application.
    .PARAMETER Cloud
        Target environment: Entra (default) or AD.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$UserPrincipalName,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret,
        [Parameter()]
        [ValidateSet('Entra','AD')]
        [string]$Cloud = 'Entra'
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-STLog -Message "Disable-GraphUser $UserPrincipalName" -Structured -Metadata @{ user = $UserPrincipalName }
    $result = 'Success'
    try {
        if ($Cloud -eq 'Entra') {
            $token = Get-GraphAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
            $headers = @{ Authorization = "Bearer $token" }
            $url = "https://graph.microsoft.com/v1.0/users/$UserPrincipalName"
            $body = @{ accountEnabled = $false } | ConvertTo-Json
            if ($PSCmdlet.ShouldProcess($UserPrincipalName, 'Disable user')) {
                Invoke-RestMethod -Uri $url -Headers $headers -Method Patch -Body $body -ContentType 'application/json'
            }
        } else {
            Import-Module ActiveDirectory -ErrorAction Stop
            if ($PSCmdlet.ShouldProcess($UserPrincipalName, 'Disable user')) {
                Set-ADUser -Identity $UserPrincipalName -Enabled:$false -ErrorAction Stop
            }
        }
        Write-STStatus "Disabled user $UserPrincipalName" -Level SUCCESS -Log
    } catch {
        $result = 'Failure'
        Write-STStatus "Failed to disable $UserPrincipalName: $_" -Level ERROR -Log
        Write-STLog -Message "Disable-GraphUser failed: $_" -Level ERROR
        throw
    } finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Disable-GraphUser' -Result $result -Duration $sw.Elapsed
    }
}
