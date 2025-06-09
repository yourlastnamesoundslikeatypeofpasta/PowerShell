function Out-CompanyPlace {
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(ValueFromPipeline)]
        [ValidateNotNull()]
        [pscustomobject]$InputObject
    )
    process {
        $InputObject | Format-Table DisplayName, Type, City, State, CountryOrRegion, PlaceId
    }
}
