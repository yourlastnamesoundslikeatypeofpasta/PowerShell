function Import-SupportToolsLogging {
    [CmdletBinding()]
    param()
    $modulePath = Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1'
    Import-Module $modulePath -Force -ErrorAction SilentlyContinue -DisableNameChecking
}
