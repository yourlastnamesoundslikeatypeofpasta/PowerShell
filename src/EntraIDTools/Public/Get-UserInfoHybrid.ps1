function Get-UserInfoHybrid {
    <#
    .SYNOPSIS
        Combines Entra ID and Active Directory user attributes.
    .DESCRIPTION
        Retrieves a user's details from Microsoft Graph using
        Get-GraphUserDetails and merges them with specified
        on-premises Active Directory attributes.
    .PARAMETER UserPrincipalName
        User principal name of the account.
    .PARAMETER TenantId
        GUID identifier for the Entra ID tenant.
    .PARAMETER ClientId
        Application (client) ID used for Graph authentication.
    .PARAMETER ClientSecret
        Optional client secret for the application.
    .PARAMETER ADProperties
        Additional Active Directory attributes to include.
    .EXAMPLE
        Get-UserInfoHybrid -UserPrincipalName user@contoso.com -TenantId 00000000-0000-0000-0000-000000000000 -ClientId 11111111-1111-1111-1111-111111111111
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$UserPrincipalName,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret,
        [Parameter(Mandatory = $false)]
        [string[]]$ADProperties = @('SamAccountName','Enabled','LastLogonDate')
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-STLog -Message "Get-UserInfoHybrid $UserPrincipalName" -Structured -Metadata @{ user = $UserPrincipalName }
    $result = 'Success'
    try {
        $graphUser = Get-GraphUserDetails -UserPrincipalName $UserPrincipalName -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
        $adUser = Get-ADUser -Filter "UserPrincipalName -eq '$UserPrincipalName'" -Properties $ADProperties

        $combined = [ordered]@{
            UserPrincipalName = $graphUser.UserPrincipalName
            DisplayName       = $graphUser.DisplayName
            Licenses          = $graphUser.Licenses
            Groups            = $graphUser.Groups
            LastSignIn        = $graphUser.LastSignIn
        }
        foreach ($prop in $ADProperties) {
            $combined[$prop] = $adUser.$prop
        }
        return [pscustomobject]$combined
    } catch {
        $result = 'Failure'
        Write-STLog -Message "Get-UserInfoHybrid failed: $_" -Level ERROR
        throw
    } finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Get-UserInfoHybrid' -Result $result -Duration $sw.Elapsed
    }
}
