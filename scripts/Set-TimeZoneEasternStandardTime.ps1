function Set-TimeZoneEasternStandardTime {
    <#
    .SYNOPSIS
    Set time zone to Eastern Standard Time.
    
    .DESCRIPTION
    Set time zone to Eastern Standard Time using the Set-TimeZone cmdlet.
    
    .EXAMPLE
    Set-TimeZoneEasternStandardTime
    
    .NOTES
    Can be used as a one liner.
    #>
    Write-Host 'Setting time zone to Eastern Standard Time...' -ForegroundColor Cyan
    Set-TimeZone -ID "Eastern Standard Time"
    Write-Host 'Time zone updated.' -ForegroundColor Green
}

