Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue

function Set-NetAdapterMetric {
    <#
    .SYNOPSIS
    Set a network adapters metric priority
    
    .DESCRIPTION
    Using the string value of the adapter name, set the metric priority of the adapter
    
    .PARAMETER Adapter
    The name of the adapter to set the metric priority for
    The metric to assign to the adapter
    
    .EXAMPLE
    Set-NetAdapterMetric -Adapter "Ethernet" -Metric 1
    
    .NOTES
    None
    #>

[CmdletBinding()]
param (
    [Parameter()]
    [string]
    $Adapter,
    [Parameter()]
    [Int32]
    $Metric
)
Write-STStatus "Setting metric $Metric on adapter $Adapter..." -Level INFO
$Adapter = Get-NetAdapter -Name $Adapter

$Adapter | Set-NetIPInterface -InterfaceMetric $Metric
Write-STStatus 'Metric updated.' -Level SUCCESS

}


