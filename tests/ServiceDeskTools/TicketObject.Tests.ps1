. $PSScriptRoot/../TestHelpers.ps1

Describe 'TicketObject class' {
    BeforeAll {
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/TicketObject.psm1 -Force
    }

    Safe-It 'maps fields from API response' {
        $json = [pscustomobject]@{
            id          = 42
            number      = 'INC42'
            title       = 'Broken mouse'
            state       = 'open'
            priority    = 'low'
            created_at  = '2023-01-01T10:00:00Z'
            updated_at  = '2023-01-02T11:00:00Z'
            assignee    = [pscustomobject]@{ name = 'Alice' }
            requester   = [pscustomobject]@{ email = 'alice@example.com' }
            category    = 'hardware'
            subcategory = 'mouse'
            origin      = 'phone'
            type        = 'incident'
            tags        = @('hardware', 'mouse')
        }
        $ticket = [TicketObject]::FromApiResponse($json)
        $ticket.Id | Should -Be 42
        $ticket.Number | Should -Be 'INC42'
        $ticket.Title | Should -Be 'Broken mouse'
        $ticket.State | Should -Be 'open'
        $ticket.Priority | Should -Be 'low'
        $ticket.Assignee | Should -Be 'Alice'
        $ticket.Requester | Should -Be 'alice@example.com'
        $ticket.Category | Should -Be 'hardware'
        $ticket.Subcategory | Should -Be 'mouse'
        $ticket.Origin | Should -Be 'phone'
        $ticket.Type | Should -Be 'incident'
        $ticket.Tags | Should -Be @('hardware', 'mouse')
        $ticket.RawJson | Should -Match 'INC42'
    }

    Safe-It 'returns null when input is null' {
        [TicketObject]::FromApiResponse($null) | Should -Be $null
    }
}

Describe 'Ticket ID argument completer' {
    Safe-It 'registers completer for Id parameters' {
        Mock Register-ArgumentCompleter {}
        Import-Module $PSScriptRoot/../../src/ServiceDeskTools/ServiceDeskTools.psd1 -Force
        $cmds = 'Get-SDTicket', 'Set-SDTicket', 'Add-SDTicketComment', 'Get-SDTicketHistory', 'Set-SDTicketBulk'
        foreach ($c in $cmds) {
            Assert-MockCalled Register-ArgumentCompleter -ParameterFilter { $CommandName -eq $c -and $ParameterName -eq 'Id' } -Times 1
        }
    }
}
