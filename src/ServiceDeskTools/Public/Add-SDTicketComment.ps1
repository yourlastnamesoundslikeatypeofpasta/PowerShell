function Add-SDTicketComment {
    <#
    .SYNOPSIS
        Adds a comment to a Service Desk incident.
    .PARAMETER Id
        Incident ID to update.
    .PARAMETER Comment
        Text body of the comment.
    #>
    [CmdletBinding(SupportsShouldProcess=$true)]
    param(
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [int]$Id,
        [Parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]
        [string]$Comment,
        [Parameter(Mandatory=$false)]
        [switch]$ChaosMode,
        [Parameter(Mandatory=$false)]
        [switch]$Explain
    )

    if (Show-STHelpWhenExplain -Explain:$Explain) { return }

    Write-STLog -Message "Add-SDTicketComment $Id"
    $body = @{ comment = @{ body = $Comment } }
    if ($PSCmdlet.ShouldProcess("ticket $Id", 'Add comment')) {
        Invoke-SDRequest -Method 'POST' -Path "/incidents/$Id/comments.json" -Body $body -ChaosMode:$ChaosMode
    }
}

# Register argument completer for open ticket IDs
Register-ArgumentCompleter -CommandName Add-SDTicketComment -ParameterName Id -ScriptBlock {
    param($commandName, $parameterName, $wordToComplete)
    try {
        Invoke-SDRequest -Method 'GET' -Path '/incidents.json?state=open' |
            ForEach-Object id |
            Where-Object { $_ -like "$wordToComplete*" } |
            ForEach-Object {
                [System.Management.Automation.CompletionResult]::new($_, $_, 'ParameterValue', $_)
            }
    } catch {
        # ignore completion errors
    }
}
