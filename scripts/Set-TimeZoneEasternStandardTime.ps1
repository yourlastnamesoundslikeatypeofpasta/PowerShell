Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue

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
    Write-STStatus 'Setting time zone to Eastern Standard Time...' -Level INFO
    Set-TimeZone -ID "Eastern Standard Time"
    Write-STStatus 'Time zone updated.' -Level SUCCESS
}

