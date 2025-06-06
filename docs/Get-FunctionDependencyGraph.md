# Get-FunctionDependencyGraph

Generates a diagram showing how functions inside a script call each other. The command parses the target script, identifies all function definitions and then determines which of those functions invoke the others.

## Usage

```powershell
./scripts/Get-FunctionDependencyGraph.ps1 -Path ./scripts/AddUsersToGroup.ps1 -Format Graphviz
```

Specify `-Format Mermaid` to emit Mermaid markup instead of Graphviz DOT syntax. Use `-OutputFile` to write the diagram to disk.

The output can be visualized with tools like Graphviz or any online Mermaid renderer.
