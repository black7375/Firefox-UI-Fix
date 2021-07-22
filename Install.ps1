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

#** Helper Utils ***************************************************************
#== Message ====================================================================
function Lepton-ErrorMessage() {
  Write-Error "FAILED: ${args}"
  exit -1
}

function Lepton-OKMessage() {
  $local:SIZE = 50
  $local:FILLED = ""
  for ($i = 0; $i -le ($SIZE - 2); $i++) {
    $FILLED += "."
  }
  $FILLED += "OK"

  $local:message = "${args}"
  Write-Host ${message}(${FILLED}.Substring(${message}.Length))
}

#== Required Tools =============================================================
function Install-Choco() {
  # https://chocolatey.org/install
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072
  iex ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))
}

function Check-Git() {
  if( -Not (Get-Command git) ) {
    Install-Choco
  }

  Lepton-OKMessage "Required - git"
}

#== PATH / File ================================================================
$currentDir = (Get-Location).path

function Filter-Path() {
  Param (
    [Parameter(Mandatory=$true, Position=0)]
    [string[]] $pathList,
    [Parameter(Position=1)]
    [string]   $option = "Any"
  )

  return $pathList.Where({ Test-Path -Path "$_" -PathType "${option}" })
}

function Copy-Auto() {
  Param (
    [Parameter(Mandatory=$true, Position=0)]
    [string] $file,
    [Parameter(Mandatory=$true, Position=1)]
    [string] $target
  )

  if ( "${file}" -eq "${target}" ) {
    Write-Host "'${file}' and ${target} are same file"
    return 0
  }

  if ( Test-Path -Path "${target}" ) {
    Write-Host "${target} alreay exist."
    Write-Host "Now Backup.."
    Copy-Auto "${target}" "${target}.bak"
    Write-Host ""
  }

  Copy-Item -Path "${file}" -Destination "${target}" -Force
}

function Move-Auto() {
  Param (
    [Parameter(Mandatory=$true, Position=0)]
    [string] $file,
    [Parameter(Mandatory=$true, Position=1)]
    [string] $target
  )

  if ( "${file}" -eq "${target}" ) {
    Write-Host "'${file}' and ${target} are same file"
    return 0
  }

  if ( Test-Path -Path "${target}" ) {
    Write-Host "${target} alreay exist."
    Write-Host "Now Backup.."
    Move-Auto "${target}" "${target}.bak"
    Write-Host ""
  }

  Move-Item -Path "${file}" -Destination "${target}" -Force
}

function Restore-Auto() {
  Param (
    [Parameter(Mandatory=$true, Position=0)]
    [string] $file
  )
  $local:target = "${file}.bak"

  if ( Test-Path -Path "${file}" ) {
    Remove-Item "${file}" -Recurse -Force
  }
  Move-Item -Path "${target}" -Destination "${file}" -Force

  $local:loopupTarget = "${target}.bak"
  if ( Test-Path -Path "${lookupTarget}" ) {
    Restore-Auto "${target}"
  }
}

function Write-File() {
  Param (
    [Parameter(Mandatory=$true, Position=0)]
    [string] $filePath,
    [Parameter(Position=1)]
    [string] $fileContent = ""
  )

  if ( "${fileContent}" -eq "" ) {
    New-Item -Path "${filePath}" -Force
  }
  else {
    Out-File -FilePath "${filePath}" -InputObject "${fileContent}" -Force
  }
}

#== INI File ================================================================
# https://devblogs.microsoft.com/scripting/use-powershell-to-work-with-any-ini-file/
function Get-IniContent () {
  Param (
    [Parameter(Mandatory=$true, Position=0)]
    [string] $filePath
  )

  $ini = @{}
  switch -regex -file $filePath {
    “^\[(.+)\]” {
      # Section
      $section = $matches[1]
      $ini[$section] = @{}
      $CommentCount = 0
    }
    “^(;.*)$” {
      # Comment
      $value = $matches[1]
      $CommentCount = $CommentCount + 1
      $name = “Comment” + $CommentCount
      $ini[$section][$name] = $value
    }
    “(.+?)\s*=(.*)” {
      # Key
      $name,$value = $matches[1..2]
      $ini[$section][$name] = $value
    }
  }
  return $ini
}

function Out-IniFile() {
  Param (
    [Parameter(Mandatory=$true, Position=0)]
    [string] $filePath,
    [Parameter(Position=1)]
    [hashtable] $iniObject = @{}
  )

  # Create new file
  New-Item -Path "${filePath}" -Force
  $local:outFile = New-Item -ItemType file -Path "${filepath}"

  foreach ($i in $iniObject.keys) {
    if (!($($iniObject[$i].GetType().Name) -eq “Hashtable”)) {
      #No Sections
      Add-Content -Path $outFile -Value “$i=$($iniObject[$i])”
    }
    else {
      #Sections
      Add-Content -Path $outFile -Value “[$i]”
      Foreach ($j in ($iniObject[$i].keys | Sort-Object)) {
        if ($j -match “^Comment[\d]+”) {
          Add-Content -Path $outFile -Value “$($iniObject[$i][$j])”
        }
        else {
          Add-Content -Path $outFile -Value “$j=$($iniObject[$i][$j])”
        }

      }
      Add-Content -Path $outFile -Value “”
    }
  }
}

#** Main ***********************************************************************
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
$ProfileInfoFile = "profiles.ini"

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

function Check-FirefoxProfileConfigurations {
  param ([string[]]$InstallDirectories)
  Write-Host -Nonewline "Checking profile info files... "

  foreach ($Install in $InstallDirectories) {
    if (-not ($Test-Path -Path (-Join $Install, "\", $ProfileInfoFile))) {
      Write-Error "Unable to find $ProfileInfoFile for install $Install"
      exit -1
    }
  }

  Write-Host "[found]"
}

function Get-FirefoxProfilePaths {
  param ([string[]]$InstallDirectories)

  Write-Host -Nonewline "Checking path information for profiles... "

  $AbsoluteProfiles = @()

  foreach ($Directory in $InstallDirectories) {
    $InfoFileContents = (Get-Content -Path (-Join $Directory, "\", $ProfileInfoFile)) -Split "\n"
    $PathNames = $InfoFileContents
      .Where({$_ -Match "Path=.+"})
      .ForEach({$_ -Replace "Path=",""})
      .ForEach({$AbsoluteProfiles += (-Join $Directory, "\", $_)})
  }

  # TODO: error handling
  return $AbsoluteProfiles
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
  Check-FirefoxProfileConfigurations $InstallationDirectories

  # TODO: read profile paths in from profiles.ini files
  $AsboluteProfilePaths = Get-FirefoxProfilePaths

  # TODO: install if in install mode
  #Install-LeptonToProfiles $AbsoluteProfilePaths
}

Check-Help
Install-Lepton
