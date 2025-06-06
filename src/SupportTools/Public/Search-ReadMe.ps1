
function Search-ReadMe {
    <#
    .SYNOPSIS
    A tool to find a recursively find a readme file on a windows system.
    
    .DESCRIPTION
    This tool will search for a readme file on a windows system. 
    It will search the entire C drive for a file with the name readme in it.
    It will return the name, directory, last write time, and length of the file.
    
    This tool was written (which could be used as a one-liner) to assist in
    locating a readme file. Infected machines of a ransomware attack at a previous company 
    had a readme file located somewhere on the system. This tool was written to assst.
    
    .EXAMPLE
    Search-ReadMe
    
    .NOTES
    This tool can be used as a one-liner.
    #>

    $results = Get-ChildItem -Path C:\*readme*.txt -Recurse -File -ErrorAction SilentlyContinue

    return $results

}

