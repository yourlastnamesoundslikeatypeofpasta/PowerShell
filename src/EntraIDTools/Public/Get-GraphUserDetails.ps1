function Get-GraphUserDetails {
    <#
    .SYNOPSIS
        Retrieves a user's details from Microsoft Graph.

    .DESCRIPTION
        Authenticates using MSAL and queries Graph for the user's basic info,
        assigned licenses, group membership and last sign-in time.
        Activity is logged and telemetry is recorded.

    .PARAMETER UserPrincipalName
        User principal name (UPN) of the account to retrieve.

    .PARAMETER TenantId
        GUID identifier for the Entra ID/Azure AD tenant containing the user.

    .PARAMETER ClientId
        Application (client) ID used for Microsoft Graph authentication.

    .PARAMETER ClientSecret
        Optional client secret for the application when using app-only
        authentication.

    .PARAMETER CsvPath
        Optional file path to save the returned details as a CSV file.

    .PARAMETER HtmlPath
        Optional file path to save the returned details as an HTML report.

    .EXAMPLE
        Get-GraphUserDetails -UserPrincipalName user@contoso.com -TenantId
        00000000-0000-0000-0000-000000000000 -ClientId
        11111111-1111-1111-1111-111111111111

        Retrieves user information and writes the details to the console.

    .EXAMPLE
        Get-GraphUserDetails -UserPrincipalName user@contoso.com -TenantId
        00000000-0000-0000-0000-000000000000 -ClientId
        11111111-1111-1111-1111-111111111111 -CsvPath ./user.csv -HtmlPath
        ./user.html

        Retrieves the user information and exports the results to both CSV and
        HTML files.
    #>
    [CmdletBinding()]
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
        [ValidateNotNullOrEmpty()]
        [string]$CsvPath,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$HtmlPath
        ,
        [Parameter()]
        [ValidateSet('Entra','AD')]
        [string]$Cloud = 'Entra'
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-STLog -Message "Get-GraphUserDetails $UserPrincipalName" -Structured -Metadata @{ user = $UserPrincipalName }
    $result = 'Success'
    try {
        if ($Cloud -eq 'Entra') {
            $token = Get-GraphAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
            $headers = @{ Authorization = "Bearer $token" }

            $userUrl = "https://graph.microsoft.com/v1.0/users/$UserPrincipalName?`$select=id,displayName,userPrincipalName"
            $user = Invoke-RestMethod -Uri $userUrl -Headers $headers -Method Get

            $licUrl = "https://graph.microsoft.com/v1.0/users/$($user.id)/licenseDetails"
            $licenses = Invoke-RestMethod -Uri $licUrl -Headers $headers -Method Get

            $grpUrl = "https://graph.microsoft.com/v1.0/users/$($user.id)/memberOf?`$select=displayName"
            $groups = Invoke-RestMethod -Uri $grpUrl -Headers $headers -Method Get

            $signUrl = "https://graph.microsoft.com/beta/users/$($user.id)?`$select=signInActivity"
            $sign = Invoke-RestMethod -Uri $signUrl -Headers $headers -Method Get

            $details = [pscustomobject]@{
                UserPrincipalName = $user.userPrincipalName
                DisplayName       = $user.displayName
                Licenses          = ($licenses.value.skuPartNumber -join ',')
                Groups            = ($groups.value.displayName -join ',')
                LastSignIn        = $sign.signInActivity.lastSignInDateTime
            }
        } else {
            Import-Module ActiveDirectory -ErrorAction Stop
            $user = Get-ADUser -Filter "UserPrincipalName -eq '$UserPrincipalName'" -Properties MemberOf,LastLogonDate -ErrorAction Stop
            $groups = $user.MemberOf | Get-ADGroup | Select-Object -ExpandProperty Name
            $details = [pscustomobject]@{
                UserPrincipalName = $user.UserPrincipalName
                DisplayName       = $user.Name
                Licenses          = ''
                Groups            = ($groups -join ',')
                LastSignIn        = $user.LastLogonDate
            }
        }

        if ($CsvPath)  { $details | Export-Csv -Path $CsvPath -NoTypeInformation }
        if ($HtmlPath) { $details | ConvertTo-Html -Title 'User Details' | Out-File -FilePath $HtmlPath }

        return $details
    } catch {
        $result = 'Failure'
        Write-STLog -Message "Get-GraphUserDetails failed: $_" -Level ERROR
        throw
    } finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Get-GraphUserDetails' -Result $result -Duration $sw.Elapsed
    }
}
