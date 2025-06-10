param(
    [int]$Port = 8080
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue

$stopServer = $false
$cancelHandler = {
    param($sender, $eventArgs)
    $global:stopServer = $true
    $eventArgs.Cancel = $true
}
[Console]::add_CancelKeyPress($cancelHandler)

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$Port/")

try {
    $listener.Start()
    Write-STStatus "Mock API server listening on http://localhost:$Port/" -Level SUCCESS
    while ($listener.IsListening -and -not $global:stopServer) {
        try {
            $context = $listener.GetContext()
        } catch {
            continue
        }

        $path = $context.Request.RawUrl
        try {
            switch -Wildcard ($path) {
                '/graph/*' {
                    $payload = @{ value = 'fake Graph response' } | ConvertTo-Json
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
                    $context.Response.ContentType = 'application/json'
                    $context.Response.ContentLength64 = $bytes.Length
                    $context.Response.OutputStream.Write($bytes,0,$bytes.Length)
                }
                '/pnp/*' {
                    $payload = @{ value = 'fake PnP response' } | ConvertTo-Json
                    $bytes = [System.Text.Encoding]::UTF8.GetBytes($payload)
                    $context.Response.ContentType = 'application/json'
                    $context.Response.ContentLength64 = $bytes.Length
                    $context.Response.OutputStream.Write($bytes,0,$bytes.Length)
                }
                default {
                    $context.Response.StatusCode = 404
                }
            }
        } catch {
            Write-STStatus -Message "Failed to write response: $($_.Exception.Message)" -Level ERROR
        } finally {
            try { $context.Response.Close() } catch {}
        }
    }
}
finally {
    $listener.Stop()
    [Console]::remove_CancelKeyPress($cancelHandler)
}
