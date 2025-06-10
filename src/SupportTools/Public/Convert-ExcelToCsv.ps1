function Convert-ExcelToCsv {
    <#
    .SYNOPSIS
        Converts an Excel workbook to CSV.

    .DESCRIPTION
        Uses Excel COM automation to save the provided workbook as a CSV file and
        returns the resulting CSV object.

    .PARAMETER XlsxFilePath
        Path to the Excel workbook to convert.

    .PARAMETER TranscriptPath
        Optional path for a transcript log file.

    .EXAMPLE
        Convert-ExcelToCsv -XlsxFilePath ./Book.xlsx -TranscriptPath ./convert.log

        Converts the specified workbook and writes a transcript to `convert.log`.

    .NOTES
        Requires Microsoft Excel to be installed on the system.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory)]
        [string]$XlsxFilePath,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath
    )

    try {
        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }

        if (-not $PSCmdlet.ShouldProcess($XlsxFilePath, 'Convert to CSV')) { return }
        Write-STStatus "Converting $XlsxFilePath to CSV..." -Level INFO
        $excel = New-Object -ComObject Excel.Application
        $workbook = $excel.Workbooks.Open($XlsxFilePath)

        try {
            $xlsxFile = Get-ChildItem $XlsxFilePath
            $directory = $xlsxFile.DirectoryName
            $basename = $xlsxFile.BaseName
            $csvFilePath = Join-Path $directory "$basename.csv"

            $xlCSV = 6
            foreach ($worksheet in $workbook.Worksheets) {
                $worksheet.SaveAs($csvFilePath, $xlCSV)
            }

            Write-STStatus "CSV saved to $csvFilePath" -Level SUCCESS
            return (Import-Csv $csvFilePath)
        } finally {
            if ($null -ne $workbook) { $workbook.Close($false) }
            if ($null -ne $excel) { $excel.Quit() }
            if ($null -ne $workbook) {
                [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook)
            }
            if ($null -ne $excel) {
                [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel)
            }
            [GC]::Collect()
            [GC]::WaitForPendingFinalizers()
        }
    } catch {
        return New-STErrorRecord -Message $_.Exception.Message -Exception $_.Exception
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}
