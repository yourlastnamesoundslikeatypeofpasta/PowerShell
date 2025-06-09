function Import-SupportToolsLogging {
    [CmdletBinding()]
    param()
    $modulePath = Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1'
    try {
        Import-Module $modulePath -Force -ErrorAction Stop -DisableNameChecking
    } catch {
        Write-STStatus -Message "Failed to import Logging module: $($_.Exception.Message)" -Level WARN
    }
}
