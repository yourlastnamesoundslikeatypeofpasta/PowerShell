function Invoke-DeploymentTemplate {
    <#
    .SYNOPSIS
        Runs the sample deployment template script.
    .DESCRIPTION
        This cmdlet executes SS_DEPLOYMENT_TEMPLATE.ps1 from the repository's
        scripts folder with any additional arguments supplied.
    #>
    [CmdletBinding()]
    param(
        [Parameter(ValueFromRemainingArguments=$true, ValueFromPipeline=$true)]
        [object[]]$Arguments
    )
    process {
        Invoke-ScriptFile -Name "SS_DEPLOYMENT_TEMPLATE.ps1" -Args $Arguments
    }
}
