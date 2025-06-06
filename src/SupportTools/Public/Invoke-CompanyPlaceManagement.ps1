function Invoke-CompanyPlaceManagement {
    <#
    .SYNOPSIS
        Manages Microsoft Places entries for your organization.
    .DESCRIPTION
        Supports creation, editing, and retrieval of Place records using the MicrosoftPlaces module.
    .PARAMETER Action
        The action to perform: Get, Create, or Edit.
    .PARAMETER DisplayName
        The visible name of the place.
    .PARAMETER Type
        Required for Get. Building, Floor, Section, or Desk.
    .PARAMETER AutoAddFloor
        When creating a building, adds a default floor 1.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [ValidateSet('Get','Create','Edit')]
        [string]$Action,
        [Parameter(Mandatory)]
        [string]$DisplayName,
        [ValidateSet('Building','Floor','Section','Desk')]
        [string]$Type = 'Building',
        [string]$Street,
        [string]$City,
        [string]$State,
        [string]$PostalCode,
        [string]$CountryOrRegion,
        [switch]$AutoAddFloor
    )
    if (-not (Get-Command Get-PlaceV3 -ErrorAction SilentlyContinue)) {
        try {
            Import-Module MicrosoftPlaces -ErrorAction Stop
            Connect-MicrosoftPlaces -ErrorAction Stop
        } catch {
            Write-Error "Failed to load MicrosoftPlaces module or connect: $_"
            return
        }
    } else {
        Connect-MicrosoftPlaces -ErrorAction SilentlyContinue | Out-Null
    }
    switch ($Action) {
        'Get' {
            if (-not $Type) {
                Write-Error "For 'Get', the -Type parameter is required."
                return
            }
            $results = Get-PlaceV3 -Type $Type | Where-Object { $_.DisplayName -like "$DisplayName" }
            if ($results) {
                $results | Format-Table DisplayName, Type, City, State, CountryOrRegion, PlaceId
                return $results
            } else {
                Write-Warning "No matching places found for '$DisplayName' of type '$Type'"
            }
        }
        'Create' {
            $existing = Get-PlaceV3 -Type $Type | Where-Object { $_.DisplayName -eq $DisplayName }
            if ($existing) {
                Write-Host "⚠️ Place already exists: $DisplayName" -ForegroundColor Yellow
                return $existing
            }
            $params = @{ Type = $Type; DisplayName = $DisplayName; Street = $Street; City = $City; State = $State; PostalCode = $PostalCode; CountryOrRegion = $CountryOrRegion }
            $place = New-Place @params
            Write-Host "✅ Created: $DisplayName [$($place.PlaceId)]"
            if ($Type -eq 'Building' -and $AutoAddFloor) {
                New-Place -Type Floor -Name '1' -ParentId $place.PlaceId | Out-Null
                Write-Host "➕ Added default floor '1'"
            }
            return $place
        }
        'Edit' {
            $place = Get-PlaceV3 -Type $Type | Where-Object { $_.DisplayName -eq $DisplayName }
            if (-not $place) {
                Write-Error "❌ Cannot edit. Place '$DisplayName' of type '$Type' not found."
                return
            }
            $updateParams = @{ Identity = "$($place.DisplayName)_$($place.PlaceId)" }
            if ($Street) { $updateParams['Street'] = $Street }
            if ($City) { $updateParams['City'] = $City }
            if ($State) { $updateParams['State'] = $State }
            if ($PostalCode) { $updateParams['PostalCode'] = $PostalCode }
            if ($CountryOrRegion) { $updateParams['CountryOrRegion'] = $CountryOrRegion }
            Set-PlaceV3 @updateParams
            Write-Host "✏️ Updated '$DisplayName' successfully."
        }
    }
}



