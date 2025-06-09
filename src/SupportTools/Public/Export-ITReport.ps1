function Export-ITReport {
    <#
    .SYNOPSIS
        Exports an arbitrary object as an IT report.
    .DESCRIPTION
        Takes any PowerShell object from the pipeline or -Data parameter
        and writes it to a file in one of three formats: HTML, CSV or JSON.
        Useful for saving log entries, audit summaries or configuration
        drift results.
    .PARAMETER Data
        The object to export. Accepts pipeline input.
    .PARAMETER Format
        Desired output format. One of HTML, CSV or JSON.
    .PARAMETER OutputPath
        Optional path for the report file. If not provided, a file name
        with a timestamp and appropriate extension is created in the
        current directory.
    .PARAMETER TranscriptPath
        Optional path to a transcript log file.
    .EXAMPLE
        Get-FailedLogin | Export-ITReport -Format CSV -OutputPath report.csv
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [psobject]$Data,
        [Parameter(Mandatory)]
        [ValidateSet('HTML','CSV','JSON')]
        [string]$Format,
        [string]$OutputPath,
        [string]$TranscriptPath
    )
    begin {
        # Collect pipeline objects in a growable list
        $items = [System.Collections.Generic.List[object]]::new()
        $osBuild = (Get-CimInstance -ClassName Win32_OperatingSystem | Select-Object -ExpandProperty BuildNumber)
        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }
    }
    process {
        # Add each augmented object without reallocating an array
        $items.Add($Data | Add-Member -NotePropertyName OsBuild -NotePropertyValue $osBuild -PassThru)
    }
    end {
        try {
            Assert-ParameterNotNull $Format 'Format'
            if (-not $OutputPath) {
                $ext = switch ($Format) {
                    'HTML' { 'html' }
                    'CSV'  { 'csv' }
                    'JSON' { 'json' }
                }
                $OutputPath = Join-Path (Get-Location) "ITReport_$((Get-Date).ToString('yyyyMMdd_HHmmss')).$ext"
            }
            switch ($Format) {
                'HTML' {
                    $items | ConvertTo-Html -PreContent '<h1>IT Report</h1>' | Out-File -FilePath $OutputPath -Encoding utf8
                }
                'CSV' {
                    $items | Export-Csv -Path $OutputPath -NoTypeInformation -Encoding utf8
                }
                'JSON' {
                    $items | ConvertTo-Json -Depth 10 | Out-File -FilePath $OutputPath -Encoding utf8
                }
            }
            Write-STStatus "Report saved to $OutputPath" -Level SUCCESS
            return [pscustomobject]@{
                OutputPath = $OutputPath
                Format     = $Format
            }
        } finally {
            if ($TranscriptPath) { Stop-Transcript | Out-Null }
        }
    }
}
