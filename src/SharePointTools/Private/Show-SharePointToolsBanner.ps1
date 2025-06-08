function Show-SharePointToolsBanner {
    <#
    .SYNOPSIS
        Displays a module loaded message.
    .EXAMPLE
        Show-SharePointToolsBanner
    #>
    Write-STDivider 'SHAREPOINTTOOLS MODULE LOADED' -Style heavy
    Write-STStatus "Run 'Get-Command -Module SharePointTools' to view available tools." -Level SUB
    Write-STLog -Message 'SharePointTools module loaded'
}

Register-SPToolsCompleters
Show-SharePointToolsBanner
