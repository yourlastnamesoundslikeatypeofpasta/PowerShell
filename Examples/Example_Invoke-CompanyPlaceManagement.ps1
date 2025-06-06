Import-Module ../src/SupportTools/SupportTools.psd1

# Get building information
Invoke-CompanyPlaceManagement -Action Get -Type Building -DisplayName "HQ*"

# Create a new building with a default floor
Invoke-CompanyPlaceManagement -Action Create -DisplayName "HQ North" -Street "1 Company Way" -City "Metropolis" -State "NY" -PostalCode "10001" -CountryOrRegion "USA" -AutoAddFloor

# Update an existing building's address
Invoke-CompanyPlaceManagement -Action Edit -DisplayName "HQ North" -Type Building -Street "2 Company Way"
