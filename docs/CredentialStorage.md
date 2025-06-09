# Secure Credential Storage Workflow

This guide demonstrates one approach for keeping credentials out of source control while still making them available to the modules in this repository.

## Install the SecretManagement modules

```powershell
Install-Module Microsoft.PowerShell.SecretManagement, Microsoft.PowerShell.SecretStore -Scope CurrentUser
```

Register the built‑in SecretStore as the default vault:

```powershell
Register-SecretVault -Name LocalStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
```

The SecretStore vault starts out locked. In unattended scenarios configure it to avoid prompting:

```powershell
Set-SecretStoreConfiguration -Scope CurrentUser -Authentication None -Interaction None
```

If you secured the store with a password, unlock it first using `Unlock-SecretStore`.

## Save secrets

Store the required application values and API tokens as secrets. Use the same names as the environment variables expected by the modules:

```powershell
Set-Secret -Name SPTOOLS_CLIENT_ID  -Secret '<client-id>'
Set-Secret -Name SPTOOLS_TENANT_ID  -Secret '<tenant-id>'
Set-Secret -Name SPTOOLS_CERT_PATH  -Secret '<path-to-pfx>'
Set-Secret -Name SD_API_TOKEN       -Secret '<service-desk-token>'
Set-Secret -Name SD_BASE_URI        -Secret 'https://helpdesk.contoso.com'
Set-Secret -Name SD_ASSET_BASE_URI  -Secret 'https://assets.contoso.com'
```

## Load environment variables

Add the following snippet to your PowerShell profile or run it before importing the modules. It retrieves the secrets and populates the environment variables used by the tools:

```powershell
$env:SPTOOLS_CLIENT_ID = Get-Secret SPTOOLS_CLIENT_ID -AsPlainText
$env:SPTOOLS_TENANT_ID = Get-Secret SPTOOLS_TENANT_ID -AsPlainText
$env:SPTOOLS_CERT_PATH = Get-Secret SPTOOLS_CERT_PATH -AsPlainText
$env:SD_API_TOKEN      = Get-Secret SD_API_TOKEN -AsPlainText
$env:SD_BASE_URI       = Get-Secret SD_BASE_URI -AsPlainText
$env:SD_ASSET_BASE_URI = Get-Secret SD_ASSET_BASE_URI -AsPlainText
```

With the variables set, you can import the modules and run the commands normally.

This workflow keeps credentials encrypted within the SecretStore and prevents accidental exposure in scripts or source control.

## Using Windows Credential Manager

If you prefer storing secrets in the built-in Windows Credential Manager, install the CredMan extension for SecretManagement and register it as a vault:

```powershell
Install-Module SecretManagement.CredMan -Scope CurrentUser
Register-SecretVault -Name WinCred -ModuleName SecretManagement.CredMan
```

Secrets saved to `WinCred` can be retrieved with `Get-Secret` the same way as the SecretStore examples above.

## Using Azure Key Vault

To pull secrets from Azure Key Vault, install the Az.KeyVault extension and register your vault:

```powershell
Install-Module Az.Accounts, Az.KeyVault -Scope CurrentUser
Register-SecretVault -Name CompanyVault -ModuleName Az.KeyVault -VaultName 'MyKeyVault'
```

After logging in with `Connect-AzAccount`, calls to `Get-Secret -Vault CompanyVault` will fetch the values directly from your key vault.
