function Register-SPToolsCompleters {
    <#
    .SYNOPSIS
        Registers tab completion for site names.
    .EXAMPLE
        Register-SPToolsCompleters
    #>
    $siteCmds = 'Get-SPToolsSiteUrl','Get-SPToolsLibraryReport','Get-SPToolsRecycleBinReport','Clear-SPToolsRecycleBin','Get-SPToolsPreservationHoldReport','Get-SPToolsAllLibraryReports','Get-SPToolsAllRecycleBinReports','Get-SPToolsFileReport','Select-SPToolsFolder'
    Register-ArgumentCompleter -CommandName $siteCmds -ParameterName SiteName -ScriptBlock {
        param($commandName,$parameterName,$wordToComplete)
        $SharePointToolsSettings.Sites.Keys | Where-Object { $_ -like "$wordToComplete*" } |
            ForEach-Object { [System.Management.Automation.CompletionResult]::new($_,$_, 'ParameterValue', $_) }
    }
}

