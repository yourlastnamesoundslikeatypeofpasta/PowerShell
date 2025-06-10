function Test-Drift {
    <#
    .SYNOPSIS
        Checks the system configuration against a baseline JSON file.
    .DESCRIPTION
        Reads a baseline definition containing timezone, hostname and service
        status expectations. Compares them with the current system and returns
        details of any deviations.
    .PARAMETER BaselinePath
        Path to a JSON file describing the expected configuration.
    .EXAMPLE
        Test-Drift -BaselinePath './baseline.json'
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateNotNullOrEmpty()]
        [string]$BaselinePath
    )
    process {
        Assert-ParameterNotNull $BaselinePath 'BaselinePath'
        $baseline = Get-STConfig -Path $BaselinePath
        # Use a List to avoid array recreation in multiple loops
        $drift = [System.Collections.Generic.List[object]]::new()

        if ($baseline.timezone) {
            $currentTz = (Get-TimeZone).Id
            if ($currentTz -ne $baseline.timezone) {
                $drift.Add([pscustomobject]@{
                    Setting  = 'Timezone'
                    Expected = $baseline.timezone
                    Actual   = $currentTz
                })
            }
        }

        if ($baseline.hostname) {
            $currentHost = if ($env:COMPUTERNAME) { $env:COMPUTERNAME } else { $env:HOSTNAME }
            if ($currentHost -ne $baseline.hostname) {
                $drift.Add([pscustomobject]@{
                    Setting  = 'Hostname'
                    Expected = $baseline.hostname
                    Actual   = $currentHost
                })
            }
        }

        if ($baseline.services) {
            foreach ($name in $baseline.services.Keys) {
                $expected = $baseline.services[$name]
                try {
                    $status = (Get-Service -Name $name).Status
                } catch {
                    $status = 'Missing'
                }
                if ($status -ne $expected) {
                    $drift.Add([pscustomobject]@{
                        Setting  = "Service:$name"
                        Expected = $expected
                        Actual   = $status
                    })
                }
            }
        }

        if ($drift.Count -eq 0) {
            Write-STStatus -Message 'System matches baseline configuration.' -Level SUCCESS
        } else {
            Write-STStatus -Message 'Configuration drift detected.' -Level WARN
            foreach ($item in $drift) {
                Write-STStatus "$($item.Setting) Expected: $($item.Expected) Actual: $($item.Actual)" -Level SUB
            }
        }
        return $drift
    }
}
