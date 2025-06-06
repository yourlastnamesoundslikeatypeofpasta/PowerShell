param(
    [int]$Port = 8080
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -ErrorAction SilentlyContinue

$listener = [System.Net.HttpListener]::new()
$listener.Prefixes.Add("http://localhost:$Port/")

try {
    $listener.Start()
    Write-STStatus "Mock API server listening on http://localhost:$Port/" -Level SUCCESS
    while ($listener.IsListening) {
        $context = $listener.GetContext()
        $path = $context.Request.RawUrl
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
        $context.Response.Close()
    }
}
finally {
    $listener.Stop()
}
