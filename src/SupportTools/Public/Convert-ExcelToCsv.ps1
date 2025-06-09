function Convert-ExcelToCsv {
    <#
    .SYNOPSIS
        Converts an Excel workbook to CSV.
    .DESCRIPTION
        Uses Excel COM automation to save the provided workbook as a CSV file and
        returns the resulting CSV object.
    .PARAMETER XlsxFilePath
        Path to the Excel workbook to convert.
    #>
    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        [Parameter(Mandatory)]
        [string]$XlsxFilePath,
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath
    )

    try {
        if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }

        Write-STStatus "Converting $XlsxFilePath to CSV..." -Level INFO
        $excel = New-Object -ComObject Excel.Application
        $workbook = $excel.Workbooks.Open($XlsxFilePath)

        $xlsxFile = Get-ChildItem $XlsxFilePath
        $directory = $xlsxFile.DirectoryName
        $basename = $xlsxFile.BaseName
        $csvFilePath = Join-Path $directory "$basename.csv"

        $xlCSV = 6
        foreach ($worksheet in $workbook.Worksheets) {
            $worksheet.SaveAs($csvFilePath, $xlCSV)
        }
        $workbook.Close($false)
        $excel.Quit()
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($workbook)
        [void][System.Runtime.InteropServices.Marshal]::ReleaseComObject($excel)
        [GC]::Collect()
        [GC]::WaitForPendingFinalizers()

        Write-STStatus "CSV saved to $csvFilePath" -Level SUCCESS
        return (Import-Csv $csvFilePath)
    }
    catch {
        return New-STErrorRecord -Message $_.Exception.Message -Exception $_.Exception
    }
    finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}
