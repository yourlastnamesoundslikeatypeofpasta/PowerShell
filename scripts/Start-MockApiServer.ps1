param(
    [int]$Port = 8080,
    [System.Net.HttpListener]$Listener
)

Import-Module (Join-Path $PSScriptRoot '..' 'src/Logging/Logging.psd1') -Force -ErrorAction SilentlyContinue

if (-not $PSBoundParameters.ContainsKey('Listener') -or -not $Listener) {
    $Listener = [System.Net.HttpListener]::new()
}

$Listener.Prefixes.Add("http://localhost:$Port/")

try {
    $Listener.Start()
    Write-STStatus "Mock API server listening on http://localhost:$Port/" -Level SUCCESS
    while ($Listener.IsListening) {
        $context = $Listener.GetContext()
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
    $Listener.Stop()
}
