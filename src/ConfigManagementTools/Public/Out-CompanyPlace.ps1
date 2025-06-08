function Out-CompanyPlace {
    [CmdletBinding()]
    param(
        [Parameter(ValueFromPipeline)]
        [pscustomobject]$InputObject
    )
    process {
        $InputObject | Format-Table DisplayName, Type, City, State, CountryOrRegion, PlaceId
    }
}
