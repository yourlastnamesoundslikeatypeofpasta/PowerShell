<#
.SYNOPSIS
Display a simple countdown.

.DESCRIPTION
Writes numbers from 10 down to 1 with a one second delay between each
number. Useful for scripts that need a brief pause or countdown.
#>

param()
Import-Module (Join-Path $PSScriptRoot '..' 'src/SupportTools/SupportTools.psd1') -Force
Start-Countdown
