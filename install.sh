#!/usr/bin/env bash

#** Helper Utils ***************************************************************
#== Message ====================================================================
lepton_error_message() {
  >&2 echo "FAILED: ${@}"
  exit 1
}

lepton_ok_message() {
  local SIZE=50
  local FILLED=""
  for ((i=0; i<=$((SIZE - 2)); i++)); do
    FILLED+="."
  done
  FILLED+="OK"

  local message="${@}"
  echo "${message}${FILLED:${#message}}"
}

lepton_spinner() {
  local chars="/-\|"

  for (( i=0; i<${#chars}; i++ )); do
    sleep 0.5
    echo -en "${chars:$i:1}" "\r"
  done
}

#== Required Tools =============================================================
PACAPT_PATH="/usr/local/bin/pacapt"
PACAPT_INSTALLED=true
pacapt_install() {
  if ! [ -x "$(command -v pacapt)" ]; then
    echo "Universal Package Manager(icy/pacapt) Download && Install(need sudo permission)"
    echo "It is installed temporarily and will be removed when installation is complete."
    sudo curl https://github.com/icy/pacapt/raw/ng/pacapt -Lo "${PACAPT_PATH}"
    sudo chmod 755 "${PACAPT_PATH}"
    sudo ln -sv "${PACAPT_PATH}" /usr/local/bin/pacman || true
    PACAPT_INSTALLED=false
  fi
  sudo pacapt -Sy
}

pacapt_uninstall() {
  if [[ "${PACAPT_INSTALLED}" == false ]]; then
    sudo rm -rf "${PACAPT}"
  fi
}

mac_command_line_developer_tools() {
   # https://unix.stackexchange.com/questions/408280/until-statement-waiting-for-process-to-finish-being-ignored
   XCODE_MESSAGE="$(osascript -e 'tell app "System Events" to display dialog "Please click install when Command Line Developer Tools appears"')"
   if [ "$XCODE_MESSAGE" = "button returned:OK" ]; then
     xcode-select --install
   else
     lepton_error_message "You have cancelled the installation, please rerun the installer."
   fi

   until [ "$(xcode-select -p 1>/dev/null 2>&1; echo $?)" -eq 0 ]; do
     lepton_spinner
   done
   echo ""
   lepton_ok_message "Installed Command Line Developer Tools"
}

check_git() {
  if ! [ -x "$(command -v git)" ]; then
    if [[ "${OSTYPE}" == "linux"* || "${OSTYPE}" == "FreeBSD" ]]; then
      pacapt_install
      sudo pacapt -S git
      pacapt_uninstall
    elif [[ "${OSTYPE}" == "darwin"* ]]; then
      mac_command_line_developer_tools
    else
      lepton_error_message "OS NOT DETECTED, couldn't install required packages. Please manually install git."
    fi
  fi

  if [[ "${OSTYPE}" == "darwin"* ]]; then
    if ! [ "$(git --help 1>/dev/null 2>&1; echo $?)" -eq 0 ]; then
      mac_command_line_developer_tools
    fi
  fi
  lepton_ok_message "Required - git"
}

#== PATH / File ================================================================
currentDir=$( cd "$(dirname $0)" ; pwd )

paths_filter() {
  local pathListName="$1" # array name
  local option="$2"

  # Set array
  eval "local pathList=(\"\${${pathListName}[@]}\")"

  # Set default option
  if [ -z "$option" ]; then
    option="-e"
  fi

  # Check path
  local foundedTargets=()
  for checkTarget in "${pathList[@]}"; do
    if [ "$option" "$checkTarget" ]; then
      foundedTargets+=("$checkTarget")
    fi
  done

  # Replace
  eval "${pathListName}=(\"\${foundedTargets[@]}\")"
}

autocp() {
  local file="${1}"
  local target="${2}"

  if [ "${file}" == "${target}" ]; then
    echo "'${file}' and ${target} are same file"
    return 0
  fi

  if [ -e "${target}" ]; then
    echo "${target} already exists."
    echo "Now making a backup.."
    autocp "${target}" "${target}.bak"
    rm -rf "${target}"
    echo ""
  fi

  cp -rf "${file}" "${target}"
}

automv() {
  local file="${1}"
  local target="${2}"

  if [ "${file}" == "${target}" ]; then
    echo "'${file}' and ${target} are same file"
    return 0
  fi

  if [ -e "${target}" ]; then
    echo "${target} already exists."
    echo "Now making a backup.."
    automv "${target}" "${target}.bak"
    echo ""
  fi

  mv -f "${file}" "${target}"
}

autorestore() {
  local file="${1}"
  local target="${file}.bak"

  if [ -e "${file}" ]; then
    rm -rf "${file}"
  fi
  mv -f  "${target}" "${file}"

  local lookupTarget="${target}.bak"
  if [ -e "${lookupTarget}" ]; then
    autorestore "${target}"
  fi
}

write_file() {
  local filePath="$1"
  local fileContent="$2"

  if [ -z "${fileContent}" ]; then
    if [ -e "${filePath}" ]; then
      rm -rf "${filePath}"
    fi
    touch "${filePath}"
  else
    echo -e "${fileContent}" | tee "${filePath}" > /dev/null
  fi
}

#== INI File ================================================================
get_ini_section() {
  local filePath="$1"

  local output="$(grep -E "^\[" "${filePath}" |sed -e "s/^\[//g" -e "s/\]$//g")"
  echo "${output}"
}
get_ini_value() {
  local filePath="$1"
  local key="$2"
  local section="$3"

  local output=""
  if [ "${section}" == "" ]; then
    output="$(grep -E "^${key}" "${filePath}" | cut -f 2 -d"=")"
    echo "${output}"
  else
    local sectionStart=""
    while IFS= read line; do
      if [[ "${sectionStart}" == "true" && "${line}" == "["* ]]; then
        return 0
      fi

      if [ "${line}" == "[${section}]" ]; then
        sectionStart="true"
      fi

      if [ "${sectionStart}" == "true" ]; then
        output="$(echo "${line}" | grep -E "^${key}" | cut -f 2 -d"=" )"
        if [ "${output}" != "" ]; then
          echo "${output}"
        fi
      fi
    done < "${filePath}"
  fi
}

set_ini_section() {
  local section="$1"
  echo "[${section}]\n"
}
set_ini_value() {
  local key="$1"
  local value="$2"

  if [ "${value}" == "" ]; then
    echo ""
  else
    echo "${key}=${value}\n"
  fi
}

#== Multiselect ================================================================
# https://stackoverflow.com/questions/45382472/bash-select-multiple-answers-at-once/54261882
multiselect() {
  echo 'Select with <space>, confirm with <enter>'

  # little helpers for terminal print control and key input
  ESC=$( printf "\033")
  cursor_blink_on()   { printf "$ESC[?25h"; }
  cursor_blink_off()  { printf "$ESC[?25l"; }
  cursor_to()         { printf "$ESC[$1;${2:-1}H"; }
  print_inactive()    { printf "$2   $1 "; }
  print_active()      { printf "$2  $ESC[7m $1 $ESC[27m"; }
  get_cursor_row()    { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
  key_input()         {
    local key
    IFS= read -rsn1 key 2>/dev/null >&2
    if [[ $key = ""      ]]; then echo enter; fi;
    if [[ $key = $'\x20' ]]; then echo space; fi;
    if [[ $key = $'\x1b' ]]; then
      read -rsn2 key
      if [[ $key = [A ]]; then echo up;    fi;
      if [[ $key = [B ]]; then echo down;  fi;
    fi
  }
  toggle_option()    {
    local arr_name=$1
    eval "local arr=(\"\${${arr_name}[@]}\")"
    local option=$2
    if [[ ${arr[option]} == true ]]; then
      arr[option]=
    else
      arr[option]=true
    fi
    eval $arr_name='("${arr[@]}")'
  }

  local retval=$1
  local options
  local defaults

  IFS=';' read -r -a options <<< "$2"
  if [[ -z $3 ]]; then
    defaults=()
  else
    IFS=';' read -r -a defaults <<< "$3"
  fi
  local selected=()

  for ((i=0; i<${#options[@]}; i++)); do
    selected+=("${defaults[i]}")
    printf "\n"
  done

  # determine current screen position for overwriting the options
  local lastrow=`get_cursor_row`
  local startrow=$(($lastrow - ${#options[@]}))

  # ensure cursor and input echoing back on upon a ctrl+c during read -s
  trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
  cursor_blink_off

  local active=0
  while true; do
    # print options by overwriting the last lines
    local idx=0
    for option in "${options[@]}"; do
      local prefix="[ ]"
      if [[ ${selected[idx]} == true ]]; then
        prefix="[x]"
      fi

      cursor_to $(($startrow + $idx))
      if [ $idx -eq $active ]; then
        print_active "$option" "$prefix"
      else
        print_inactive "$option" "$prefix"
      fi
        ((idx++))
      done

      # user key control
      case `key_input` in
        space)  toggle_option selected $active;;
        enter)  break;;
        up)     ((active--));
                if [ $active -lt 0 ]; then active=$((${#options[@]} - 1)); fi;;
        down)   ((active++));
                if [ $active -ge ${#options[@]} ]; then active=0; fi;;
      esac
    done

    # cursor position back to normal
    cursor_to $lastrow
    printf "\n"
    cursor_blink_on

    eval $retval='("${selected[@]}")'
}

#** Profile ********************************************************************
#== Profile Dir ================================================================
firefoxProfileDirPaths=(
  "${HOME}/.mozilla/firefox"
  "${HOME}/.waterfox"
  "${HOME}/.librewolf"
  "${HOME}/.ghostery browser"
  "${HOME}/.pulse-browser"
  "${HOME}/.firedragon"
  "${HOME}/.cachy"
  "${HOME}/.local/opt/tor-browser/app/Browser/TorBrowser/Data/Browser"
  "${HOME}/.var/app/org.mozilla.firefox/.mozilla/firefox"
  "${HOME}/snap/firefox/common/.mozilla/firefox"
  "${HOME}/Library/Application Support/Firefox"
  "${HOME}/Library/Application Support/Waterfox"
  "${HOME}/Library/Application Support/libreWolf"
  "${HOME}/Library/Application Support/Ghostery Browser"
  "${HOME}/Library/Application Support/pulse-browser"
  "${HOME}/Library/Application Support/TorBrowser/Browser"
)

check_profile_dir() {
  local profileDir="$1"
  if [ "${profileDir}" != "" ]; then
    firefoxProfileDirPaths=("${profileDir}")
  fi

  paths_filter firefoxProfileDirPaths -d

  local foundCount="${#firefoxProfileDirPaths[@]}"
  if [ "${foundCount}" -eq 0 ];  then
    lepton_error_message "Unable to find firefox profile dir."
  fi

  lepton_ok_message "Profiles dir found"
}

#== Profile Info ===============================================================
PROFILEINFOFILE="profiles.ini"
check_profile_ini() {
  for profileDir in "${firefoxProfileDirPaths[@]}"; do
    if [ ! -f "${profileDir}/${PROFILEINFOFILE}" ]; then
      lepton_error_message "Unable to find ${PROFILEINFOFILE} at ${profileDir}"
    fi
  done

  lepton_ok_message "Profiles info file found"
}

#== Profile PATH ===============================================================
firefoxProfilePaths=()
update_profile_paths() {
  local IFS=$'\n'
  for profileDir in "${firefoxProfileDirPaths[@]}"; do
    local escapeDir=$(echo "${profileDir}" | sed "s|\/|\\\/|g")
    firefoxProfilePaths+=($(
      get_ini_value "${profileDir}/${PROFILEINFOFILE}" "Path" |
      sed "s/^/${escapeDir}\//"
    ))
  done

  local foundCount="${#firefoxProfilePaths[@]}"
  if ! [ "${foundCount}" -eq 0 ]; then
    lepton_ok_message "Profile paths updated"
  else
    lepton_error_message "Doesn't exist profiles"
  fi
}

select_profile() {
  local profileName="$1"

  if [ "${profileName}" != "" ]; then
    local targetPath=""
    for profilePath in "${firefoxProfilePaths[@]}"; do
      if [[ "${profilePath}" == *"${profileName}" ]]; then
        targetPath="${profilePath}"
        break
      fi
    done

    if [ "${targetPath}" != "" ]; then
      lepton_ok_message "Profile, \"${profileName}\" found"
      firefoxProfilePaths=("${targetPath}")
    else
      lepton_error_message "Unable to find ${profileName}"
    fi
  else
    local foundCount="${#firefoxProfilePaths[@]}"
    if [ "${foundCount}" -eq 1 ]; then
      lepton_ok_message "Auto detected profile"
    else
      local multiPaths=""
      for profilePath in "${firefoxProfilePaths[@]}"; do
        multiPaths+="${profilePath};"
      done
      multiselect profileSelected "${multiPaths}"

      local targetPaths=()
      for ((i=0; i<"${#profileSelected[@]}"; i++)); do
        local result="${profileSelected[${i}]}"
        if [ "$result" == "true" ]; then
          targetPaths+=("${firefoxProfilePaths[${i}]}")
        fi
      done

      firefoxProfilePaths=("${targetPaths[@]}")
      foundCount="${#firefoxProfilePaths[@]}"
      if [ "${foundCount}" -eq 0 ]; then
        lepton_error_message "Please select profiles"
      fi

      lepton_ok_message "Multi selected profiles"
    fi
  fi
}

#** Lepton Info File ***********************************************************
#== Info File format & update policy ===========================================
## `LEPTON` file format
# If this file exist in same directory as the `userChrome.css` file,
# it is recognized as the "Lepton" installation directory.
# [Info]
# Branch=master | photon-style | proton-style
# Ver=<git tag> | <git hash> | [NULL]

## `lepton.ini` file Format
# [Profile Name]
# Type=Local | Release | Git
# Branch=master | photon-style | proton-style
# Ver=<git tag> | <git hash> | [NULL]
# Path=<Full PATH>

## Update Policy
# Type
# - Local(unknown): force latest commit update
# - Release(<git tag>): force latest tag update
# - Git<git hash>: latest commit update

#== Lepton Info ================================================================
LEPTONINFOFILE="lepton.ini"
check_lepton_ini() {
  for profileDir in "${firefoxProfileDirPaths[@]}"; do
    if [ ! -f "${profileDir}/${LEPTONINFOFILE}" ]; then
      lepton_error_message "Unable to find ${LEPTONINFOFILE} at ${profileDir}"
    fi
  done

  lepton_ok_message "Lepton info file found"
}

#== Create info file ===========================================================
# We should always create a new one, as it also takes into account the possibility of setting it manually.
# Updates happen infrequently, so the creation overhead  is less significant.

get_profile_dir() {
  local profilePath="$1"
  for profileDir in "${firefoxProfileDirPaths[@]}"; do
    if [[ "${profilePath}" == "${profileDir}"* ]]; then
      echo "${profileDir}"
      return 0
    fi
  done
}

CHROMEINFOFILE="LEPTON"
write_lepton_info() {
  # Init info
  local output=""
  local prevDir="${firefoxProfileDirPaths[0]}"
  local latestPath="${firefoxProfilePaths[${#firefoxProfilePaths[@]} - 1]}"
  for profilePath in "${firefoxProfilePaths[@]}"; do
    local LEPTONINFOPATH="${profilePath}/chrome/${CHROMEINFOFILE}"
    local LEPTONGITPATH="${profilePath}/chrome/.git"

    # Profile info
    local Type=""
    local Ver=""
    local Branch=""
    local Path=""
    if [ -f "${LEPTONINFOPATH}" ]; then
      if [ -d "${LEPTONGITPATH}" ]; then
        Type="Git"
        Ver=$(   git --git-dir "${LEPTONGITPATH}" rev-parse HEAD)
        Branch=$(git --git-dir "${LEPTONGITPATH}" rev-parse --abbrev-ref HEAD)
      else
        Type=$(  get_ini_value "${LEPTONINFOPATH}" "TYPE"  )
        Ver=$(   get_ini_value "${LEPTONINFOPATH}" "Ver"   )
        Branch=$(get_ini_value "${LEPTONINFOPATH}" "Branch")

        if [ "${Type}" == "" ]; then
          Type="Local"
        fi
      fi

      Path="${profilePath}"
    fi

    # Flushing
    local profileDir=$(get_profile_dir "${profilePath}")
    local profileName=$(basename "${profilePath}")
    if [ "${prevDir}" != "${profileDir}" ]; then
      write_file "${prevDir}/${LEPTONINFOFILE}" "${output}"
      output=""
    fi

    # Make output contents
    if [ -f "${LEPTONINFOPATH}" ]; then
      output="${output}$(set_ini_section ${profileName})"
    fi
    for key in "Type" "Branch" "Ver" "Path"; do
      eval "local value=\${${key}}"
      output="${output}$(set_ini_value "${key}" "${value}")"
    done

    # Latest element flushing
    if [ "${profilePath}" == "${latestPath}" ]; then
      write_file "${profileDir}/${LEPTONINFOFILE}" "${output}"
    fi
    prevDir="${profileDir}"
  done

  # Verify
  check_lepton_ini
  lepton_ok_message "Lepton info file created"
}

#** Install ********************************************************************
#== Install Types ==============================================================
updateMode=""
leptonBranch="master"
select_distribution() {
  local selectedDistribution=""
  select distribution in "Original(default)" "Photon-Style" "Proton-Style" "Update"; do
    selectedDistribution="${distribution}"
    case "${distribution}" in
      "Original(default)") leptonBranch="master";       break;;
      "Photon-Style")      leptonBranch="photon-style"; break;;
      "Proton-Style")      leptonBranch="proton-style"; break;;
      "Update")            updateMode="true";           break;;
      *)                   echo "Invalid option, reselect please.";;
    esac
  done
  lepton_ok_message "Selected ${selectedDistribution}"
}

leptonInstallType="Network" # Other types: Local, Release
check_install_type() {
  local targetListName="${1}"
  local installType="${2}"

  eval "local targetCount=\${#${targetListName}[@]}"
  paths_filter "${targetListName}"
  eval "local foundCount=\${#${targetListName}[@]}"

  if [ "${targetCount}" -eq "${foundCount}" ]; then
    leptonInstallType="${installType}"
  fi
}

checkLocalFiles=(
  userChrome.css
  userContent.css
  icons
)
checkReleaseFiles=(
  user.js
  chrome/userChrome.css
  chrome/userContent.css
  chrome/icons
)
check_install_types() {
  check_install_type checkLocalFiles   "Local"
  check_install_type checkReleaseFiles "Release"

  lepton_ok_message "Checked install type: ${leptonInstallType}"
  if [ "${leptonInstallType}" == "Network" ]; then
    select_distribution
  fi
  if [ "${leptonInstallType}" == "Local" ]; then
    if [ -d ".git" ]; then
      select_distribution
      git checkout "${leptonBranch}"
    fi
  fi
}

#== Custom Install =============================================================
customFiles=(
  user-overrides.js
  userChrome-overrides.css
  userContent-overrides.css
)
localCustomFiles=("${customFiles[@]}")

customFileExist=""
check_custom_files() {
  paths_filter localCustomFiles

  if [ "${#localCustomFiles[@]}" -gt 0 ]; then
    customFileExist="true"
    lepton_ok_message "Check custom file detected"

    for customFile in "${localCustomFiles[@]}"; do
      echo "- ${customFile}"
    done
  fi
}

copy_custom_files() {
  if [ "${customFileExist}" == "true" ]; then
    # If Release or Network mode, Local is passed (Already copied)
    if [ "${leptonInstallType}" != "Local" ]; then
      for profilePath in "${firefoxProfilePaths[@]}"; do
        for customFile in "${localCustomFiles[@]}"; do
          if [ "${customFile}" == "user-overrides.js" ]; then
            autocp "${customFile}" "${profilePath}/${customFile}"
          else
            autocp "${customFile}" "${profilePath}/chrome/${customFile}"
          fi
        done
      done
    fi

    lepton_ok_message "End custom file copy"
  fi
}

customMethod=""
customReset=""
customAppend=""
set_custom_method() {
  local menuAppend="Append - Maintain changes in existing files and apply custom"
  local menuOverwrite="Overwrite - After initializing the change, apply only custom"
  local menuNone="None - Maintain changes in existing files"
  local menuReset="Reset- Reset to pure lepton theme without custom"

  echo "Select custom method"
  select applyMethod in "${menuAppend}" "${menuOverwrite}" "${menuNone}" "${menuReset}"; do
    case "${applyMethod}" in
      "${menuAppend}")
        customMethod="Append"
        customAppend="true"
        break;;
      "${menuOverwrite}")
        customMethod="Overwrite"
        customReset="true"
        customAppend="true"
        break;;
      "${menuNone}")
        customMethod="None"
        break;;
      "${menuReset}")
        customMethod="Reset"
        customReset="true"
        break;;
      *)
        echo "Invalid option, reselect please.";;
     esac
  done

  lepton_ok_message "Selected ${customMethod}"
}

customFileApplied=""
apply_custom_file() {
  local profilePath=$1
  local targetPath=$2
  local customPath=$3
  local otherCustomPath=$4

  local leptonDir="${profilePath}/chrome"
  local gitDir="${leptonDir}/.git"
  if [ -f "${customPath}" ]; then
    customPathApplied="true"

    if [ -z "${customMethod}" ]; then
      set_custom_method
    fi

    if [ "${customReset}" == "true" ]; then
      if [[ "${targetPath}"  == *"user.js" ]]; then
        \cp -f "${leptonDir}/user.js" "${targetPath}"
      else
        git --git-dir "${gitDir}" --work-tree "${leptonDir}" checkout HEAD -- "${targetPath}"
      fi
    fi
    if [ "${customAppend}" == "true" ]; then
      # Apply without duplication
      if ! grep -Fq "$(echo $(cat "${customPath}"))" <(echo "$(echo $(cat "${targetPath}"))"); then
        cat "${customPath}" >> "${targetPath}"
      fi
    fi
  elif [ -n "${otherCustomPath}" ]; then
    apply_custom_file "${profilePath}" "${targetPath}" "${otherCustomPath}"
  fi
}

apply_custom_files() {
  for profilePath in "${firefoxProfilePaths[@]}"; do
    for customFile in "${customFiles[@]}"; do
      local targetFile="${customFile//-overrides/}"
      if [ "${customFile}" == "user-overrides.js" ]; then
        local targetPath="${profilePath}/${targetFile}"
        local customPath="${profilePath}/user-overrides.js"
        local otherCustomPath="${profilePath}/chrome/user-overrides.js"
        apply_custom_file "${profilePath}" "${targetPath}" "${customPath}" "${otherCustomPath}"
      else
        apply_custom_file "${profilePath}" "${profilePath}/chrome/${targetFile}" "${profilePath}/chrome/${customFile}"
      fi
    done
  done

  if [ "${customFileApplied}" == "true" ]; then
    lepton_ok_message "End custom file applied"
  fi
}

#== Install Helpers ============================================================
chromeDuplicate=""
check_chrome_exist() {
  if [ -e "chrome" ] && [ ! -f "chrome/${LEPTONINFOFILE}" ]; then
    chromeDuplicate="true"
    automv chrome chrome.bak
    lepton_ok_message "Backup files"
  fi
}
check_chrome_restore() {
  if [ "${chromeDuplicate}" == "true" ]; then
    autorestore chrome
    lepton_ok_message "End restore files"
  fi
  lepton_ok_message "End check restore files"
}

clean_lepton() {
  if [ ! "${chromeDuplicate}" == "true" ] && [ -e "chrome" ]; then
    rm -rf chrome
  fi
  lepton_ok_message "End clean files"
}
clone_lepton() {
  local branch="$1"

  if [ -z "${branch}" ]; then
    branch="${leptonBranch}"
  fi

  git clone -b "${branch}" https://github.com/black7375/Firefox-UI-Fix.git chrome
  if ! [ -d "chrome" ]; then
    lepton_error_message "Unable to find downloaded files"
  fi
}

copy_lepton() {
  local chromeDir="$1"
  local userJSPath="$2"

  if [ -z "${chromeDir}" ]; then
    chromeDir="chrome"
  fi
  if [ -z "${userJSPath}" ]; then
    userJSPath="${chromeDir}/user.js"
  fi

  for profilePath in "${firefoxProfilePaths[@]}"; do
    autocp "${userJSPath}" "${profilePath}/user.js"
    autocp "${chromeDir}" "${profilePath}/chrome"
  done
  lepton_ok_message "End profile copy"
}

#== Each Install ===============================================================
install_local() {
  copy_lepton "${currentDir}" "user.js"
  copy_custom_files

  apply_custom_files
}

install_release() {
  copy_lepton "chrome" "user.js"
  copy_custom_files

  apply_custom_files
}

install_network() {
  check_chrome_exist
  check_git

  clone_lepton
  copy_lepton
  copy_custom_files

  clean_lepton
  check_chrome_restore
  apply_custom_files
}

install_profile() {
  lepton_ok_message "Started install"

  case "${leptonInstallType}" in
    "Local")   install_local   ;;
    "Release") install_release ;;
    "Network") install_network ;;
  esac

  lepton_ok_message "End install"
}

#** Update *********************************************************************
file_stash() {
  local leptonDir=$1
  local gitDir=$2
  if [[ $(git --git-dir "${gitDir}" --work-tree "${leptonDir}" diff --stat) != '' ]]; then
    git --git-dir "${gitDir}" --work-tree "${leptonDir}" stash
  fi
}
file_restore() {
  local leptonDir=$1
  local gitDir=$2
  local gitDirty=$3
  if [ -n "${gitDirty}" ]; then
    git --git-dir "${gitDir}" --work-tree "${leptonDir}" stash pop --quiet
  fi
}

update_profile() {
  check_git
  for profileDir in "${firefoxProfileDirPaths[@]}"; do
    local LEPTONINFOPATH="${profileDir}/${LEPTONINFOFILE}"
    local sections=($(get_ini_section "${LEPTONINFOPATH}"))
    if [ ! -z "${sections}" ]; then
      for section in "${sections[@]}"; do
        local Type=$(  get_ini_value "${LEPTONINFOPATH}" "Type"   "${section}")
        local Branch=$(get_ini_value "${LEPTONINFOPATH}" "Branch" "${section}")
        local Path=$(  get_ini_value "${LEPTONINFOPATH}" "Path"   "${section}")

        local leptonDir="${Path}/chrome"
        local gitDir="${leptonDir}/.git"
        if [ "${Type}" == "Git" ]; then
          local gitDirty=$(file_stash "${leptonDir}" "${gitDir}")

          git --git-dir "${gitDir}" --work-tree "${leptonDir}" checkout "${Branch}"
          git --git-dir "${gitDir}" --work-tree "${leptonDir}" pull --no-edit

          file_restore "${leptonDir}" "${gitDir}" "${gitDirty}"
        elif [ "${Type}" == "Local" ] || [ "${Type}" == "Release" ]; then
          check_chrome_exist
          clone_lepton

          firefoxProfilePaths=("${Path}")
          copy_lepton

          if [ -z "${Branch}" ]; then
            Branch="${leptonBranch}"
          fi
          git --git-dir "${gitDir}" --work-tree "${leptonDir}" checkout "${Branch}"

          if [ "${Type}" == "Release" ]; then
            local Ver=$(git --git-dir "${LEPTONINFOFILE}" describe --tags --abbrev=0)
            git --git-dir "${gitDir}" --work-tree "${leptonDir}" checkout "tags/${Ver}"
          fi

          clean_lepton
          check_chrome_restore
        else
          lepton_error_message "Unable to find update type, ${Type} at ${section}"
        fi
      done
    fi
  done

  apply_custom_files
}

#** Main ***********************************************************************
install_lepton() {
  local profileDir=""
  local profileName=""

  # Get options.
  while getopts 'u:f:p:h' flag; do
    case "${flag}" in
      u) updateMode="true"       ;;
      f) profileDir="${OPTARG}"  ;;
      p) profileName="${OPTARG}" ;;
      h)
        echo "Lepton Theme Install Script:"
        echo "  -u run to update mode"
        echo "  -f <firefox_profile_folder_path>. Set custom Firefox profile folder path."
        echo "  -p <profile_name>. Set custom profile name."
        echo "  -h to show this message."
        exit 0
        ;;
    esac
  done

  check_install_types

  check_profile_dir "${profileDir}"
  check_profile_ini
  update_profile_paths
  write_lepton_info

  check_custom_files

  # Install Mode
  if [ "${updateMode}" == true ]; then
    update_profile
  else # Install Mode
    select_profile "${profileName}"
    install_profile
  fi

  write_lepton_info
}

install_lepton "$@"
