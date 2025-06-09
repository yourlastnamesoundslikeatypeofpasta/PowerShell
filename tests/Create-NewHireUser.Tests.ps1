. $PSScriptRoot/TestHelpers.ps1
Describe 'Create-NewHireUser script' {
    BeforeAll {
        function Search-SDTicket {}
        function Set-SDTicket {}
        function Install-Module {}
        function Import-Module {}
        function Connect-MgGraph {}
        function Disconnect-MgGraph {}
        function New-MgUser {}
        . $PSScriptRoot/../scripts/Create-NewHireUser.ps1
    }
    BeforeEach {
        Mock Search-SDTicket { @([pscustomobject]@{ Id = 1; RawJson = '{"custom_fields":{"firstName":"John","lastName":"Doe","userPrincipalName":"john.doe@contoso.com"}}' }) }
        Mock Set-SDTicket {}
        Mock Install-Module {}
        Mock Import-Module {}
        Mock Connect-MgGraph {}
        Mock Disconnect-MgGraph {}
        Mock New-MgUser {}
    }
    Safe-It 'creates a user and resolves the ticket' {
        Start-Main -PollMinutes 1 -Once | Out-Null
        Assert-MockCalled Search-SDTicket -Times 1
        Assert-MockCalled New-MgUser -Times 1
        Assert-MockCalled Set-SDTicket -Times 1 -ParameterFilter { $Id -eq 1 }
    }
}
