---
external help file: SupportTools-help.xml
Module Name: ConfigManagementTools
online version:
schema: 2.0.0
---

# Invoke-CompanyPlaceManagement

## SYNOPSIS
Manages Microsoft Places entries for your organization.

## SYNTAX

```
Invoke-CompanyPlaceManagement [-Action] <String> [-DisplayName] <String> [[-Type] <String>]
 [[-Street] <String>] [[-City] <String>] [[-State] <String>] [[-PostalCode] <String>]
 [[-CountryOrRegion] <String>] [-AutoAddFloor] [[-TranscriptPath] <String>]
 [-ProgressAction <ActionPreference>] [<CommonParameters>]
```

## DESCRIPTION
Supports creation, editing, and retrieval of Place records using the MicrosoftPlaces module.

## EXAMPLES

### Example 1
```powershell
PS C:\> # Get building information
Invoke-CompanyPlaceManagement -Action Get -Type Building -DisplayName "HQ*" | Out-CompanyPlace

# Create a new building with a default floor
Invoke-CompanyPlaceManagement -Action Create -DisplayName "HQ North" -Street "1 Company Way" -City "Metropolis" -State "NY" -PostalCode "10001" -CountryOrRegion "USA" -AutoAddFloor

# Update an existing building's address
Invoke-CompanyPlaceManagement -Action Edit -DisplayName "HQ North" -Type Building -Street "2 Company Way"
```

Demonstrates typical usage of Invoke-CompanyPlaceManagement.

## PARAMETERS

### -Action
The action to perform: Get, Create, or Edit.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 1
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -DisplayName
The visible name of the place.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: True
Position: 2
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Type
Required for Get.
Building, Floor, Section, or Desk.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 3
Default value: Building
Accept pipeline input: False
Accept wildcard characters: False
```

### -Street
Street address for the location.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 4
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -City
City where the location resides.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 5
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -State
State or province for the location.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 6
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PostalCode
Postal code for the location.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 7
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -CountryOrRegion
Country or region for the location.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 8
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -AutoAddFloor
When creating a building, adds a default floor 1.

```yaml
Type: SwitchParameter
Parameter Sets: (All)
Aliases:

Required: False
Position: Named
Default value: False
Accept pipeline input: False
Accept wildcard characters: False
```

### -TranscriptPath
File path used to capture a transcript of this command's output and actions.

```yaml
Type: String
Parameter Sets: (All)
Aliases:

Required: False
Position: 9
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -ProgressAction
Specifies how progress is displayed.

```yaml
Type: ActionPreference
Parameter Sets: (All)
Aliases: proga

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

## NOTES

## RELATED LINKS
