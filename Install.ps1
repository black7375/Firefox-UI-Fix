<#

.SYNOPSIS
Installer for Lepton

.DESCRIPTION
Installs Lepton onto selected Firefox profiles

.INPUTS
TODO: input directories for installation?
Would need to discuss a non-interactive install system

.OUTPUTS
TODO: output directories that Lepton has been installed to?

.PARAMETER u
Specifies whether to update a current installation
Defaults to false

.PARAMETER f
Specifies a custom path to look for Firefox profiles in

.PARAMETER p
Specifies a custom name to use when creating a profile

.PARAMETER h
Shows this help message

.PARAMETER ?
Shows this help message

.PARAMETER WhatIf
Runs the installer without actioning any file copies/moves
Equivelant to a dry-run

.EXAMPLE
PS> .\Install.ps1 -u -f C:\Users\someone\ff-profiles
Updates current installations in the profile directory 'C:\Users\someone\ff-profiles'

.LINK
https://github.com/black7375/Firefox-UI-Fix#readme

#>

[CmdletBinding(
    SupportsShouldProcess = $true,
    PositionalBinding = $false
)]

param(
    [Alias("u")]
    [Switch]$Update=$false,
    [Alias("f")]
    [string]$ProfilePath,
    [Alias("p")]
    [string]$ProfileName,
    [Alias("h")]
    [Switch]$Help=$false
)

# Constants
$PSMinSupportedVersion = 2
$DefaultFirefoxProfilePaths = @("~/AppData/Roaming/Mozilla/Firefox/")

function Check-Help {
    # Cheap and dirty way of getting the same output as '-?' for '-h' and '-Help'
    if ($Help) {
        Get-Help "$PSCommandPath"
        exit 0
    }
}

function Verify-PowerShellVersion {
    $PSVersion = [int](Select-Object -Property Major -First 1 -ExpandProperty Major -InputObject $PSVersionTable.PSVersion)

    Write-Host "[$PSVersion]"
    if ($PSVersion -lt $PSMinSupportedVersion) {
        Write-Error -Category NotInstalled "You need a minimum PowerShell version of [$PSMinSupportedVersion] to use this installer"
        exit -1
    }
}

function Check-LeptonInstallFiles {
    param ([string[]]$Files)

    foreach ($item in $Files) {
        if (-not (Test-Path $item)) {
            return $false
        }
    }

    return $true
}

$InstallType = @{
    Local   = 0;
    Release = 1;
    Network = 2;
}

function Get-LeptonInstallType {
    $LocalFiles   = "userChrome.css", "userContent.css", "icons"
    $ReleaseFiles = "user.js", "chrome/userChrome.css", "chrome/userContent.css", "chrome/icons"

    $IsTypeLocal   = Check-LeptonInstallFiles $LocalFiles
    $IsTypeRelease = Check-LeptonInstallFiles $ReleaseFiles

    if ($IsTypeLocal) {
        return $InstallType.Local
    } elseif ($IsTypeRelease) {
        return $InstallType.Release
    }

    return $InstallType.Network
}

function Select-LeptonDistributionPrompt {
    # TODO: make it act like the bash installer with arrow keys + space
    Write-Host "Select a distrubution:"
    Write-Host "  (1) Original"
    Write-Host "  (2) Photon-Style"
    Write-Host "  (3) Photon-Style"
    Write-Host ""

    $SelectedBranch = ""
    while ($SelectedBranch -eq "") {
        $SelectedInput = Read-Host "Enter a distribution number (1, 2, 3)"
        
        switch ($SelectedInput) {
            "1" { $SelectedBranch = "master"; break }
            "2" { $SelectedBranch = "photon-style"; break }
            "3" { $SelectedBranch = "proton-style"; break }
            default { Write-Host "Invalid option, reselect please." }
        }
    }

    Write-Host ""
    Write-Host "Selected '$SelectedBranch'!"

    return $SelectedBranch
}

function Select-LeptonDistribution {
    Write-Host ""

    $FoundInstallType = Get-LeptonInstallType
    switch ($FoundInstallType) {
        $InstallType.Release { break }
        $InstallType.Network { $SelectedDistribution = Select-LeptonDistributionPrompt; break }
        $InstallType.Local {
            $SelectedDistribution = Select-LeptonDistributionPrompt
            $GitInstalled=$((Get-Command -ErrorAction SilentlyContinue "git").Length -eq 0)
            if ($GitInstalled && Test-Path ".git" && $PSCmdlet.ShouldProcess(".git")) {
                git checkout $LeptonBranchName
            }
            break
        }
        default { throw }
    }

    return @{
        Type = $InstallType.Network;
        Dist = $SelectedDistribution;
    }
}

function Get-TestedPaths {
    param ([string[]]$Paths)

    $FoundPaths = @()
    foreach ($pathItem in $Paths) {
        if ($Test-Path -Path $pathItem) {
            $FoundPaths += $pathItem
        }
    }

    return $FoundPaths
}

function Check-FirefoxProfileDirectories {
    param ([string]$CustomProfilePath)

    Write-Host -Nonewline "Checking Firefox profile directories... "

    $FirefoxProfilePaths = $DefaultFirefoxProfilePaths
    $FirefoxProfilePaths += $CustomProfilePath

    $FirefoxInstalls = Get-TestedPaths -Paths $FirefoxProfilePaths
    if ($FirefoxInstalls.Length -eq 0) {
        Write-Host "[not found]"
        Write-Error "Unable to find Firefox installations"
        exit -1
    }

    Write-Host "[found]"
    return $FirefoxInstalls
}

function Check-FirefoxProfileDirectories {
    param ([string]$CustomProfilePath)
    # TODO: stub
}

function Check-FirefoxProfileConfigurations {
    param ([string[]]$InstallDirectories)
    # TODO: stub
}

function Get-FirefoxProfilePaths {
    # TODO: stub
}

function Install-LeptonToProfiles {
    param ([string[]]$PathsToInstall)
    # TODO: stub
}

function Install-Lepton {
    Write-Host -NoNewline "Checking PowerShell version... "
    Verify-PowerShellVersion  # Check installed version meets minimum

    # TODO: select style distribution (Photon or Proton)
    $SelectedDistribution = Select-LeptonDistribution

    # TODO: check profile director{y,ies} (including custom)
    $InstallationDirectories = Check-FirefoxProfileDirectories $ProfilePath

    # TODO: check profile ini files exists
    #Check-FirefoxProfileConfigurations $InstallationDirectories

    # TODO: read profile paths in from profiles.ini files
    #$AsboluteProfilePaths = Get-FirefoxProfilePaths

    # TODO: install if in install mode
    #Install-LeptonToProfiles $AbsoluteProfilePaths
}

Check-Help
Install-Lepton

