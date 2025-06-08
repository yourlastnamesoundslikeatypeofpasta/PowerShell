function Get-GraphGroupDetails {
    <#
    .SYNOPSIS
        Retrieves group details from Microsoft Graph.
    .DESCRIPTION
        Queries Graph for the group's basic info and membership. Activity is logged and telemetry is recorded.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$GroupId,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$TenantId,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$ClientId,
        [Parameter()]
        [ValidateNotNullOrEmpty()]
        [string]$ClientSecret
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    Write-STLog -Message "Get-GraphGroupDetails $GroupId" -Structured -Metadata @{ group = $GroupId }
    $result = 'Success'
    try {
        $token = Get-GraphAccessToken -TenantId $TenantId -ClientId $ClientId -ClientSecret $ClientSecret
        $headers = @{ Authorization = "Bearer $token" }

        $groupUrl = "https://graph.microsoft.com/v1.0/groups/$GroupId?`$select=displayName,description"
        $group = Invoke-RestMethod -Uri $groupUrl -Headers $headers -Method Get

        $membersUrl = "https://graph.microsoft.com/v1.0/groups/$GroupId/members?`$select=displayName"
        $members = Invoke-RestMethod -Uri $membersUrl -Headers $headers -Method Get

        return [pscustomobject]@{
            GroupId     = $GroupId
            DisplayName = $group.displayName
            Description = $group.description
            Members     = ($members.value.displayName -join ',')
        }
    } catch {
        $result = 'Failure'
        Write-STLog -Message "Get-GraphGroupDetails failed: $_" -Level ERROR
        throw
    } finally {
        $sw.Stop()
        Write-STTelemetryEvent -ScriptName 'Get-GraphGroupDetails' -Result $result -Duration $sw.Elapsed
    }
}
