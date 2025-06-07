function Get-GraphUserDetails {
    <#
    .SYNOPSIS
        Retrieves a user's details from Microsoft Graph.
    .DESCRIPTION
        Authenticates using MSAL and queries Graph for the user's basic info,
        assigned licenses, group membership and last sign-in time.
        Activity is logged and telemetry is recorded.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)][string]$UserPrincipalName,
        [Parameter(Mandatory)][string]$TenantId,
        [Parameter(Mandatory)][string]$ClientId,
        [string]$ClientSecret,
        [string]$CsvPath,
        [string]$HtmlPath
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-STLog -Message "Get-GraphUserDetails $UserPrincipalName" -Structured -Metadata @{ user = $UserPrincipalName }
    $result = 'Success'
    try {
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
