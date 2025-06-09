function Import-SupportToolsLogging {
    $modulePath = Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1'
    Import-Module $modulePath -Force -ErrorAction SilentlyContinue
}
