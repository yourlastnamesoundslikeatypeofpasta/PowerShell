 <#
Convert .xlsx or .csv to .json
#>
 
function Convert-ExcelToCsv {
    <#
    .SYNOPSIS
        Convert a .xlsx to .csv.
 
    .DESCRIPTION
        Converting and skrrting.
 
    .LINK
        https://docs.microsoft.com/en-us/answers/questions/597931/convert-xlsx-to-csv-using-powershell.html
 
    .EXAMPLE
        Convert-ExcelToCsv -XlsxFilePath .\workstuff.xlsx
 
    .INPUTS
        System.String
    .OUTPUTS
        System.Array
    #>
   
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $XlsxFilePath
    )
    # initiate wb instance
    $excel = New-Object -ComObject Excel.Application
    $workbook = $excel.Workbooks.Open($XlsxFilePath)
 
    # build csv file path
    $xlsxFile = Get-ChildItem $XlsxFilePath
    $directory = $xlsxFile.BaseName
    $basename = $xlsxFile.BaseName
    $csvFileExtension = '.csv'
    $csvFilePath = "$($directory)\$($basename)$($csvFileExtension)"
 
    # save as csv
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
 
    # return csv obj
    $csv = Import-Csv $csvFilePath
    return $csv
 

}
 
function Convert-CsvToJson {
        <#
    .SYNOPSIS
        Convert a .csv to .json.
 
    .DESCRIPTION
        Converting and skrrting.
 
    .EXAMPLE
        Convert-CsvToJson -Csv $csv
 
    .INPUTS
        System.Array
    .OUTPUTS
        System.Object
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [array]
        $Csv
    )
    # link about json depth
    # https://www.jonathanmedd.net/2017/01/convertto-json-working-with-the-depth-parameter.html
    # $json = $Csv | ConvertTo-Json -Depth 10
 
    # link about compressing json
    # https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.utility/convertto-json?view=powershell-5.1#example-2
    # $json = $csv | ConvertTo-Json -Compress
 
    $json = $csv | ConvertTo-Json
    return $json
}
 
function Export-Json {
        <#
    .SYNOPSIS
        Export csv object to .json file.
 
    .DESCRIPTION
        We done.
 
    .EXAMPLE
        Export-Json -Json $json
 
    .INPUTS
        System.Object
        System.String
    .OUTPUTS
        No output.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [object]
        $Json,
 
        [Parameter()]
        [string]
        $OutFilePath
    )
    $Json | Add-Content -Path $OutFilePath
    $jsonFile = Get-ChildItem $OutFilePath
    $jsonFileAbsPath = $jsonFile.FullName
    Write-Information -MessageData "File saved: $jsonFileAbsPath" -InformationAction Continue
}
 
function Convert-ExcelCSVToJSON {
    <#
    .SYNOPSIS
        Convert a .xlsx to .csv.
 
    .DESCRIPTION
        Converting and skrrting.
 
    .LINK
        https://docs.microsoft.com/en-us/answers/questions/597931/convert-xlsx-to-csv-using-powershell.html
 
    .EXAMPLE
        Convert-ExcelToCsv -XlsxFilePath .\workstuff.xlsx
 
    .INPUTS
        System.String
    .OUTPUTS
        No output.
    #>
    [CmdletBinding()]
    param (
        [Parameter()]
        [string]
        $FilePath,
        [Parameter()]
        [string]
        $OutFilePath
    )
 
    # check file type
    $file = Get-ChildItem $FilePath
    $fileExtension = $file.Extension
    $handledExtensions = @(
        '.csv'
        '.xlsx'
    )    
 
    # handle accordingly
    if ($handledExtensions -contains $fileExtension) {
        if ($fileExtension -eq '.csv') {
            # .csv -> .json
 
            # easy way
            # Import-Csv -Path foo.csv | ConvertTo-Json | Add-Content -Path foo.json
 
            $csvObject = Import-Csv -Path $FilePath
            $jsonObject = Convert-CsvToJson -Csv $csvObject
            Export-Json -Json $jsonObject -OutFilePath $OutFilePath
 
        }
        elseif ($fileExtension -eq '.xlsx') {
 
            # .xlsx -> .csv -> .json
            $csvObject = Convert-ExcelToCsv -XlsxFilePath $FilePath
            $jsonObject = Convert-CsvToJson -Csv $csvObject
            Export-Json -Json $jsonObject -OutFilePath $OutFilePath
 
        }
        else {
            Write-Error -Message 'Idk how you got here'
        }
    }
    else {
        # https://media.giphy.com/media/lL20ZCkHV511xPNCSp/giphy-downsized-large.gif
        Write-Error -Message "File extension unhandled: $fileExtension"
    }
}
 
