function Search-ReadMe {
    <#
    .SYNOPSIS
        Searches README files for a provided term.
    .DESCRIPTION
        Launches the Search-ReadMe.ps1 script from the scripts directory with
        the specified arguments.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "Search-ReadMe.ps1" -Args $Arguments
    }
}
