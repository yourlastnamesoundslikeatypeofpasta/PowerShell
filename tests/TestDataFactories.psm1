function New-TestUser {
    [CmdletBinding()]
    param(
        [string]$UserPrincipalName = "user$(Get-Random -Minimum 1000 -Maximum 9999)@contoso.com",
        [string]$DisplayName = "User $(Get-Random -Minimum 1 -Maximum 9999)",
        [string]$Id = ([guid]::NewGuid()).Guid,
        [string]$Mail,
        [hashtable]$Extras
    )
    if (-not $Mail) { $Mail = $UserPrincipalName }
    $obj = [pscustomobject]@{
        Id                = $Id
        DisplayName       = $DisplayName
        UserPrincipalName = $UserPrincipalName
        Mail              = $Mail
    }
    if ($Extras) {
        foreach ($k in $Extras.Keys) { $obj | Add-Member -NotePropertyName $k -NotePropertyValue $Extras[$k] -Force }
    }
    return $obj
}

function New-TestAuditResult {
    [CmdletBinding()]
    param(
        [double]$CpuPercent = [math]::Round((Get-Random -Minimum 0 -Maximum 100) + (Get-Random), 2),
        [double]$MemoryPercent = [math]::Round((Get-Random -Minimum 0 -Maximum 100) + (Get-Random), 2),
        [double]$DiskPercent = [math]::Round((Get-Random -Minimum 0 -Maximum 100) + (Get-Random), 2),
        [double]$NetworkMbps = [math]::Round(Get-Random -Minimum 0 -Maximum 1000, 2),
        [string]$Uptime = (New-TimeSpan -Minutes (Get-Random -Minimum 1 -Maximum 10000)).ToString(),
        [string]$TicketId,
        [hashtable]$Extras
    )
    $obj = [pscustomobject]@{
        CpuPercent    = $CpuPercent
        MemoryPercent = $MemoryPercent
        DiskPercent   = $DiskPercent
        NetworkMbps   = $NetworkMbps
        Uptime        = $Uptime
    }
    if ($PSBoundParameters.ContainsKey('TicketId')) {
        $obj | Add-Member -NotePropertyName TicketId -NotePropertyValue $TicketId -Force
    }
    if ($Extras) {
        foreach ($k in $Extras.Keys) { $obj | Add-Member -NotePropertyName $k -NotePropertyValue $Extras[$k] -Force }
    }
    return $obj
}

Export-ModuleMember -Function 'New-TestUser', 'New-TestAuditResult'
