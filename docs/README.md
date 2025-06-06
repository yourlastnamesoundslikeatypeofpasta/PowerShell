# Documentation Overview

This folder contains usage guides for the PowerShell modules and commands provided in this repository. Each Markdown file describes a single function or provides general guidance. When in doubt, run `Get-Help <Command>` in PowerShell to see the inline help that matches these documents.

The key guides are:

- [Quickstart](./Quickstart.md) – short steps to install the modules and run common commands.
- [User Guide](./UserGuide.md) – detailed deployment information and security notes.
- [SupportTools](./SupportTools.md), [SharePointTools](./SharePointTools.md), [ServiceDeskTools](./ServiceDeskTools.md) – high level summaries of each module and the commands they expose.
- [Credential Storage](./CredentialStorage.md) – recommended approach to store secrets securely.
- [Module Style Guide](./ModuleStyleGuide.md) – how scripts display progress messages and log output.
- [Get-FunctionDependencyGraph](./Get-FunctionDependencyGraph.md) – generate a visual map of function calls in a script.

Command specific help topics live in the `SupportTools`, `SharePointTools` and `ServiceDeskTools` subfolders.
