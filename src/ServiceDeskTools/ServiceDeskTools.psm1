$PublicDir = Join-Path $PSScriptRoot 'Public'
$PrivateDir = Join-Path $PSScriptRoot 'Private'

Get-ChildItem -Path "$PrivateDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }
Get-ChildItem -Path "$PublicDir/*.ps1" -ErrorAction SilentlyContinue | ForEach-Object { . $_.FullName }

Export-ModuleMember -Function 'Get-SDTicket','New-SDTicket','Set-SDTicket'
