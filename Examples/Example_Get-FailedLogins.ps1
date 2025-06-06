Import-Module ../src/SupportTools/SupportTools.psd1
Get-FailedLogins -ComputerName $env:COMPUTERNAME
