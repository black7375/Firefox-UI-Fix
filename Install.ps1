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

#** Select Menu ****************************************************************
# https://github.com/chrisseroka/ps-menu
function Check-PsMenu() {
  if(-Not (Get-InstalledModule ps-menu -ErrorAction silentlycontinue)) {
    Set-PSRepository PSGallery -InstallationPolicy Trusted
    Install-Module -Name ps-menu -Confirm:$False -Force
  }
}

function DrawMenu {
  param ($menuItems, $menuPosition, $Multiselect, $selection)
  $l = $menuItems.length
  for ($i = 0; $i -le $l; $i++) {
    if ($menuItems[$i] -ne $null){
      $item = $menuItems[$i]
      if ($Multiselect) {
        if ($selection -contains $i){
          $item = '[x] ' + $item
        }
        else {
          $item = '[ ] ' + $item
        }
      }
      if ($i -eq $menuPosition) {
        Write-Host "> $($item)" -ForegroundColor Green
      }
      else {
	Write-Host "  $($item)"
      }
    }
  }
}

function Toggle-Selection {
  param ($pos, [array]$selection)
  if ($selection -contains $pos){
    $result = $selection | where {$_ -ne $pos}
  }
  else {
    $selection += $pos
    $result = $selection
  }
  $result
}

function Menu {
  param ([array]$menuItems, [switch]$ReturnIndex=$false, [switch]$Multiselect)
  $vkeycode = 0
  $pos = 0
  $selection = @()
  if ($menuItems.Length -gt 0) {
    try {
      [console]::CursorVisible=$false #prevents cursor flickering
      DrawMenu $menuItems $pos $Multiselect $selection
      While ($vkeycode -ne 13 -and $vkeycode -ne 27) {
        $press = $host.ui.rawui.readkey("NoEcho,IncludeKeyDown")
        $vkeycode = $press.virtualkeycode
        If ($vkeycode -eq 38 -or $press.Character -eq 'k') {$pos--}
        If ($vkeycode -eq 40 -or $press.Character -eq 'j') {$pos++}
        If ($vkeycode -eq 36) { $pos = 0 }
        If ($vkeycode -eq 35) { $pos = $menuItems.length - 1 }
        If ($press.Character -eq ' ') { $selection = Toggle-Selection $pos $selection }
        if ($pos -lt 0) {$pos = 0}
        If ($vkeycode -eq 27) {$pos = $null }
        if ($pos -ge $menuItems.length) {$pos = $menuItems.length -1}
        if ($vkeycode -ne 27) {
          $startPos = [System.Console]::CursorTop - $menuItems.Length
          [System.Console]::SetCursorPosition(0, $startPos)
          DrawMenu $menuItems $pos $Multiselect $selection
        }
      }
    }
    finally {
      [System.Console]::SetCursorPosition(0, $startPos + $menuItems.Length)
      [console]::CursorVisible = $true
    }
  }
  else {
    $pos = $null
  }

  if ($ReturnIndex -eq $false -and $pos -ne $null)  {
    if ($Multiselect){
      return $menuItems[$selection]
    }
    else {
      return $menuItems[$pos]
    }
  }
  else {
    if ($Multiselect) {
      return $selection
    }
    else {
      return $pos
    }
  }
}

#** Profile ********************************************************************
#== Profile Dir ================================================================
# $HOME = (get-psprovider 'FileSystem').Home
$firefoxProfileDirPaths = @(
  "${HOME}\AppData\Roaming\Mozilla\Firefox",
  "${HOME}\AppData\Roaming\LibreWolf"
)

function Check-ProfileDir() {
  Param (
    [Parameter(Position=0)]
    [string] $profileDir = ""
  )

  if ( "${profileDir}" -ne "" ) {
    $firefoxProfileDirPaths = @("${profileDir}")
  }


  $firefoxProfileDirPaths = Filter-Path $firefoxProfileDirPaths "Container"

  if ( $firefoxProfileDirPaths.Length -eq 0 ) {
    Lepton-ErrorMessage "Unable to find firefox profile dir."
  }

  Lepton-OKMessage "Profiles dir found"
}

#== Profile Info ===============================================================
$PROFILEINFOFILE="profiles.ini"
function Check-ProfileIni() {
  foreach ( $profileDir in $firefoxProfileDirPaths ) {
    if ( -Not (Test-Path -Path "${profileDir}/${PROFILEINFOFILE}" -PathType "Leaf") ) {
      Lepton-ErrorMessage "Unable to find ${PROFILEINFOFILE} at ${profileDir}"
    }
  }

  Lepton-OKMessage "Profiles info file found"
}

#== Profile PATH ===============================================================
$firefoxProfilePaths = @()
function Update-ProfilePaths() {
  foreach ( $profileDir in $firefoxProfileDirPaths ) {
    $local:iniContent = Get-IniContent "${profiledir}/${PROFILEINFOFILE}"
    $firefoxProfilePaths += $iniContent.Values.Path
  }

  if ( $firefoxProfilePaths.Length -ne 0 ) {
    Lepton-OkMessage "Profile paths updated"
  }
  else {
    Lepton-ErrorMessage "Doesn't exist profiles"
  }
}

# TODO: Multi select support
function Select-Profile() {
  Param (
    [Parameter(Position=0)]
    [string] $profileName = ""
  )

  if ( "${profileName}" -ne "" ) {
    $local:targetPath = ""
    foreach ( $profilePath in $firefoxProfilePaths ) {
      if ( "${profilePath}" -like "*${profileName}" ) {
        $targetPath = "${profilePath}"
        break
      }
    }

    if ( "${targetPath}" -ne "" ) {
      Lepton-OkMessage "Profile, `"${profileName}`" found"
      $firefoxProfilePaths = @("${targetPath}")
    }
    else {
      Lepton-ErrorMessage "Unable to find ${profileName}"
    }
  else
    if ( $firefoxProfilePaths.Length -eq 1 ) {
      Lepton-OkMessage "Auto detected profile"
    }
    else {
      $firefoxProfilePaths = Menu $firefoxProfilePaths

      if ( $firefoxProfilePaths.Length -eq 0 ) {
        Lepton-ErrorMessage "Please select profiles"
      }

      Lepton-OkMessage "Selected profile"
    }
  }
}

#** Lepton Info File ***********************************************************
# If you interst RFC, see install.sh

#== Lepton Info ================================================================
$LEPTONINFOFILE ="lepton.ini"
function Check-LeptonIni() {
  foreach ( $profileDir in $firefoxProfileDirPaths ) {
    if ( -Not (Test-Path -Path "${profileDir}/${LEPTONINFOFILE}") ) {
      Lepton-ErrorMessage "Unable to find ${LEPTONINFOFILE} at ${profileDir}"
    }
  }

  Lepton-OkMessage "Lepton info file found"
}

#== Create info file ===========================================================
# We should always create a new one, as it also takes into account the possibility of setting it manually.
# Updates happen infrequently, so the creation overhead  is less significant.

$CHROMEINFOFILE="LEPTON"
function Write-LeptonInfo() {
  # Init info
  $local:output     = @{}
  $local:prevDir    = Split-Path $firefoxProfilePaths[0] -Parent
  $local:latestPath = ( $firefoxProfilePaths | Select-Object -Last 1 )
  foreach ( $profilePath in $firefoxProfilePaths ) {
    $local:LEPTONINFOPATH = "${profilePath}/chrome/${CHROMEINFOFILE}"
    $local:LEPTONGITPATH  = "${profilePath}/chrome/.git"

    # Profile info
    $local:Type   = ""
    $local:Ver    = ""
    $local:Branch = ""
    $local:Path   = ""
    if ( Test-Path -Path "${LEPTONINFOPATH}" ) {
      if ( Test-Path -Path "${LEPTONGITPATH}" -PathType "Container" ) {
        $Type   = "Git"
        $Ver    = $(git --git-dir "${LEPTONGITPATH}" rev-parse HEAD)
        $Branch = $(git --git-dir "${LEPTONGITPATH}" rev-parse --abbrev-ref HEAD)
      }
      else {
        $local:iniContent = Get-IniContent "${LEPTONINFOPATH}"
        $Type   = $iniContent["Info"]["Type"]
        $Ver    = $iniContent["Info"]["Ver"]
        $Branch = $iniContent["Info"]["Branch"]

        if ( "${Type}" -eq "" ) {
          $Type = "Local"
        }
      }

      $Path = "${profilePath}"
    }

    # Flushing
    $local:profileDir  = Split-Path "${profilePath}" -Parent
    $local:profileName = Split-Path "${profilePath}" -Leaf
    if ( "${prevDir}" -ne "${profileDir}" ) {
      Out-IniFile "${prevDir}/${LEPTONINFOFILE}" $output
      $output = @{}
    }

    # Make output contents
    foreach ( $key in @("Type", "Branch", "Ver", "Path") ) {
      $local:value = Get-Variable -Name "${key}"
      if ( "$value" -ne $null ) {
        $output["${profileName}"] += @{"${key}" = "${value}"}
      }
    }

    # Latest element flushing
    if ( "${profilePath}" -eq "${latestPath}" ) {
      Out-IniFile "${profileDir}/${LEPTONINFOFILE}" $output
    }
    $prevDir = "${profileDir}"
  }

  # Verify
  Check-LeptonIni
  Lepton-OkMessage "Lepton info file created"
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
