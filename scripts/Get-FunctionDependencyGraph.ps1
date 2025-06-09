<#+
.SYNOPSIS
    Generates a dependency map of functions defined in a script.
.DESCRIPTION
    Parses the specified PowerShell script using the abstract syntax tree (AST)
    and determines which functions call other functions within the same file.
    The map can be exported as Graphviz DOT or Mermaid markup for visualization.
.PARAMETER Path
    Path to the script file to analyze.
.PARAMETER Format
    Output format of the diagram. Either 'Graphviz' or 'Mermaid'. Defaults to
    Graphviz.
.PARAMETER OutputFile
    Optional path to write the diagram. When omitted the diagram text is
    returned to the pipeline.
.EXAMPLE
    ./Get-FunctionDependencyGraph.ps1 -Path ./scripts/AddUsersToGroup.ps1 -Format Mermaid
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory)]
    [string]$Path,

    [ValidateSet('Graphviz', 'Mermaid')]
    [string]$Format = 'Graphviz',

    [string]$OutputFile
)

$tokens = $null
$errors = $null
$ast = [System.Management.Automation.Language.Parser]::ParseFile($Path, [ref]$tokens, [ref]$errors)
if ($errors) { throw 'Parsing errors were encountered.' }

$functions = @{}
$ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true) | ForEach-Object {
    $functions[$_.Name] = @()
}

foreach ($fn in $ast.FindAll({ param($n) $n -is [System.Management.Automation.Language.FunctionDefinitionAst] }, $true)) {
    $called = $fn.Body.FindAll({ param($n) $n -is [System.Management.Automation.Language.CommandAst] }, $true) |
        ForEach-Object { $_.GetCommandName() } |
        Where-Object { $_ -and $functions.ContainsKey($_) } |
        Select-Object -Unique
    $functions[$fn.Name] = $called
}

$edges = foreach ($name in $functions.Keys) {
    foreach ($target in $functions[$name]) {
        [pscustomobject]@{ From = $name; To = $target }
    }
}

$lines = switch ($Format) {
    'Graphviz' {
        'digraph G {'
        foreach ($e in $edges) { '    "{0}" -> "{1}"' -f $e.From, $e.To }
        '}'
    }
    'Mermaid' {
        'graph TD'
        foreach ($e in $edges) { '    {0} --> {1}' -f $e.From, $e.To }
    }
}

$diagram = $lines -join [Environment]::NewLine
if ($OutputFile) { $diagram | Set-Content -Path $OutputFile -Encoding utf8 }
$diagram
