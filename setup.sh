#!/bin/bash
set -e

# Step 1: Install PowerShell 7.4.1
echo "[*] Installing PowerShell 7.4.1..."
wget -q https://github.com/PowerShell/PowerShell/releases/download/v7.4.1/powershell-7.4.1-linux-x64.tar.gz
mkdir -p ~/powershell
tar -xzf ./powershell-7.4.1-linux-x64.tar.gz -C ~/powershell
rm ./powershell-7.4.1-linux-x64.tar.gz

# Step 2: Add pwsh to PATH
export PATH="$HOME/powershell:$PATH"

# Step 3: Enable git rerere
echo "[*] Enabling git rerere..."
git config --global rerere.enabled true

# Step 4: Install Pester (AllUsers for container-wide use)
echo "[*] Installing Pester module..."
~/powershell/pwsh -Command 'Install-Module -Name Pester -Force -Scope AllUsers'

# Step 5: Run Pester tests with configuration
echo "[*] Running Pester tests..."
~/powershell/pwsh -Command '
  $config = Import-PowerShellDataFile "./PesterConfiguration.psd1";
  Invoke-Pester -Configuration $config
'

