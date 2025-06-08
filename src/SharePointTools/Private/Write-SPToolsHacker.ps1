function Write-SPToolsHacker {
    <#
    .SYNOPSIS
        Writes a formatted status message to the log.
    .PARAMETER Message
        Text to log.
    .PARAMETER Level
        Severity level for the message.
    .EXAMPLE
        Write-SPToolsHacker -Message 'Done' -Level SUCCESS
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [ValidateNotNullOrEmpty()]
        [string]$Message,
        [ValidateSet('INFO','SUCCESS','ERROR','WARN','SUB','FINAL','FATAL')]
        [string]$Level = 'INFO',
        [hashtable]$Metadata
    )
    process {
        Write-STStatus -Message $Message -Level $Level -Log
        if ($Level -in @('SUCCESS','ERROR','WARN','FATAL')) {
            $meta = @{ tool = 'SharePointTools'; level = $Level }
            if ($Metadata) { foreach ($k in $Metadata.Keys) { $meta[$k] = $Metadata[$k] } }
            Write-STLog -Message $Message -Level $Level -Structured -Metadata $meta
        }

    }
}
