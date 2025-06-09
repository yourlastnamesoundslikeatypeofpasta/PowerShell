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
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateSet('Get','Create','Edit')]
        [ValidateNotNullOrEmpty()]
        [string]$Action,
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$DisplayName,
        [Parameter(Mandatory = $false)]
        [ValidateSet('Building','Floor','Section','Desk')]
        [ValidateNotNullOrEmpty()]
        [string]$Type = 'Building',
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$Street,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$City,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$State,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$PostalCode,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$CountryOrRegion,
        [Parameter(Mandatory = $false)]
        [switch]$AutoAddFloor,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath,
        [Parameter(Mandatory = $false)]
        [switch]$Simulate,
        [Parameter(Mandatory = $false)]
        [switch]$Explain,
        [Parameter(Mandatory = $false)]
        [object]$Logger,
        [Parameter(Mandatory = $false)]
        [object]$TelemetryClient,
        [Parameter(Mandatory = $false)]
        [object]$Config
    )

    $sw = [System.Diagnostics.Stopwatch]::StartNew()
    $result = 'Success'
    try {
        if ($Logger) {
            Import-Module $Logger -Force -ErrorAction SilentlyContinue
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue
        }
        if ($TelemetryClient) {
            Import-Module $TelemetryClient -Force -ErrorAction SilentlyContinue
        } else {
            Import-Module (Join-Path $PSScriptRoot '../../Telemetry/Telemetry.psd1') -Force -ErrorAction SilentlyContinue
        }
        if ($Config) {
            Import-Module $Config -Force -ErrorAction SilentlyContinue
        }

        if (Show-STHelpWhenExplain -Explain:$Explain) { return }

        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }
        Write-STStatus "Invoke-CompanyPlaceManagement -Action $Action" -Level SUCCESS -Log
        if ($Simulate) {
            Write-STStatus -Message 'Simulation mode active - no Microsoft Places changes will be made.' -Level WARN -Log
            $mock = [pscustomobject]@{
                Action      = $Action
                DisplayName = $DisplayName
                Simulated   = $true
                Timestamp   = Get-Date
            }
            return $mock
        }
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
                    return $results
                } else {
                    Write-STStatus "No matching places found for '$DisplayName' of type '$Type'" -Level WARN
                }
            }
            'Create' {
                $existing = Get-PlaceV3 -Type $Type | Where-Object { $_.DisplayName -eq $DisplayName }
                if ($existing) {
                    Write-STStatus "⚠️ Place already exists: $DisplayName" -Level WARN -Log
                    return $existing
                }
                $params = @{ Type = $Type; DisplayName = $DisplayName; Street = $Street; City = $City; State = $State; PostalCode = $PostalCode; CountryOrRegion = $CountryOrRegion }
                $place = New-Place @params
                Write-STStatus "✅ Created: $DisplayName [$($place.PlaceId)]" -Level SUCCESS -Log
                if ($Type -eq 'Building' -and $AutoAddFloor) {
                    New-Place -Type Floor -Name '1' -ParentId $place.PlaceId | Out-Null
                    Write-STStatus "➕ Added default floor '1'" -Level SUB -Log
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
                Write-STStatus "✏️ Updated '$DisplayName' successfully." -Level SUCCESS -Log
            }
        }

        Write-STStatus -Message 'Invoke-CompanyPlaceManagement completed' -Level FINAL -Log
    } catch {
        Write-STStatus "Invoke-CompanyPlaceManagement failed: $_" -Level ERROR -Log
        Write-STLog -Message "Invoke-CompanyPlaceManagement failed: $_" -Level ERROR -Structured:$($env:ST_LOG_STRUCTURED -eq '1')
        $result = 'Failure'
        return New-STErrorObject -Message $_.Exception.Message -Category 'SharePoint'
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
        $sw.Stop()
        Send-STMetric -MetricName 'Invoke-CompanyPlaceManagement' -Category 'Deployment' -Value $sw.Elapsed.TotalSeconds -Details @{ Result = $result }
    }
}



