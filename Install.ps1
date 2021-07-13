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

function Select-LeptonDistribution {
    param ([string]$CustomProfileDir)
    # TODO: stub
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
    Select-LeptonDistribution

    # TODO: check profile director{y,ies} (including custom)
    $InstallationDirectories = Check-FirefoxProfileDirectories $ProfilePath

    # TODO: check profile ini files exists
    Check-FirefoxProfileConfigurations $InstallationDirectories

    # TODO: read profile paths in from profiles.ini files
    $AsboluteProfilePaths = Get-FirefoxProfilePaths

    # TODO: install if in install mode
    Install-LeptonToProfiles $AbsoluteProfilePaths
}

Check-Help
Install-Lepton

