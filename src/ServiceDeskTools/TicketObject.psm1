class TicketObject {
    [int]$Id
    [string]$Number
    [string]$Title
    [string]$State
    [string]$Priority
    [datetime]$CreatedAt
    [datetime]$UpdatedAt
    [string]$Assignee
    [string]$Requester
    [string]$Category
    [string]$Subcategory
    [string]$Origin
    [string]$Type
    [string[]]$Tags
    [string]$RawJson

    TicketObject() {}

    static [TicketObject] FromApiResponse([object]$json) {
        if (-not $json) { return $null }
        $obj = [TicketObject]::new()
        $obj.Id = $json.id
        $obj.Number = $json.number
        $obj.Title = if ($json.title) { $json.title } else { $json.name }
        $obj.State = $json.state
        $obj.Priority = $json.priority
        if ($json.created_at) { $obj.CreatedAt = [datetime]$json.created_at }
        if ($json.updated_at) { $obj.UpdatedAt = [datetime]$json.updated_at }
        if ($json.assignee -and $json.assignee.name) { $obj.Assignee = $json.assignee.name }
        if ($json.requester -and $json.requester.email) { $obj.Requester = $json.requester.email }
        $obj.Category = $json.category
        $obj.Subcategory = $json.subcategory
        $obj.Origin = $json.origin
        $obj.Type = $json.type
        if ($json.tags) { $obj.Tags = @($json.tags) }
        $obj.RawJson = $json | ConvertTo-Json -Depth 10
        return $obj
    }
}
