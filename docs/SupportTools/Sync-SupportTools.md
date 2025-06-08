---
external help file: SupportTools-help.xml
Module Name: SupportTools
online version:
schema: 2.0.0
---

# Sync-SupportTools

## SYNOPSIS
Updates the SupportTools modules from a git repository.

## SYNTAX
```
Sync-SupportTools [[-RepositoryUrl] <String>] [[-InstallPath] <String>] [<CommonParameters>]
```

## DESCRIPTION
Clones the repository if it does not exist locally or pulls the latest changes when it does.
After syncing, the module manifests under `src` are imported.

## EXAMPLES
### Example 1
```powershell
PS C:\> Sync-SupportTools
```
Runs with the default settings and imports the modules.

## PARAMETERS
### -RepositoryUrl
URL of the git repository containing the modules.

### -InstallPath
Directory where the repository is cloned or updated.

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

## OUTPUTS

Custom object describing the sync result.

```
RepositoryUrl : <string>
InstallPath   : <string>
Result        : Success
```
## NOTES

## RELATED LINKS
