function Search-ReadMe {
    <#
    .SYNOPSIS
        Searches the system for readme files.

    .DESCRIPTION
        Recursively searches the C drive for files containing `readme` in the
        name and returns the file objects found.

    .PARAMETER TranscriptPath
        Optional path for a transcript log of the search.

    .EXAMPLE
        Search-ReadMe -TranscriptPath ./search.log

        Finds all readme files on the C drive and logs progress to `search.log`.

    .NOTES
        This command can take several minutes to run on large drives.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory = $false)]
        [ValidateNotNullOrEmpty()]
        [string]$TranscriptPath
    )

    $repoRoot = Split-Path -Path $PSScriptRoot -Parent | Split-Path -Parent
    $defaultsFile = Join-Path $repoRoot 'config/config.psd1'
    $STDefaults = Get-STConfig -Path $defaultsFile
    $pattern = Get-STConfigValue -Config $STDefaults -Key 'ReadmePattern'

    if ($TranscriptPath) { Start-Transcript -Path $TranscriptPath -Append | Out-Null }
    if (-not $PSCmdlet.ShouldProcess('readme search')) { return }
    try {
        Write-STStatus -Message 'Searching for readme files...' -Level INFO
        $results = Get-ChildItem -Path $pattern -Recurse -File -ErrorAction SilentlyContinue
        Write-STStatus "Found $($results.Count) file(s)." -Level SUCCESS
        return $results
    } catch {
        return New-STErrorRecord -Message $_.Exception.Message -Exception $_.Exception
    } finally {
        if ($TranscriptPath) { Stop-Transcript | Out-Null }
    }
}
