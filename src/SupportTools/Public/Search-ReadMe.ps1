function Search-ReadMe {
    <#
    .SYNOPSIS
        Searches the system for readme files.
    .DESCRIPTION
        Recursively searches the C drive for files containing 'readme' in
        the name and returns the file objects found.
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath
    )

    if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }
    try {
        Write-STStatus 'Searching for readme files...' -Level INFO
        $results = Get-ChildItem -Path C:\*readme*.txt -Recurse -File -ErrorAction SilentlyContinue
        Write-STStatus "Found $($results.Count) file(s)." -Level SUCCESS
        return $results
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}
