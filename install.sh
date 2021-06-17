#!/usr/bin/env bash

#** Helper Utils ***************************************************************
#== PATH / File ================================================================
currentDir=$( cd "$(dirname $0)" ; pwd )

paths_filter() {
  local pathListName="$1" # array name
  local option="$2"

  # Set array
  eval "local pathList=(\${${pathListName}[@]})"

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
  eval "${pathListName}=(\${foundedTargets[@]})"
}

autocopy() {
  local file="${1}"
  local target="${2}"

  if [ "${file}" == "${target}" ]; then
    echo "'${file}' and ${target} are same file"
    return 0
  fi

  if [ -e "${target}" ]; then
    echo "${target} alreay exist."
    echo "Now Backup.."
    autocopy "${target}" "${target}.bak"
    echo ""
  fi

  cp -rv "${file}" "${target}"
}

automv() {
  local file="${1}"
  local target="${2}"

  if [ "${file}" == "${target}" ]; then
    echo "'${file}' and ${target} are same file"
    return 0
  fi

  if [ -e "${target}" ]; then
    echo "${target} alreay exist."
    echo "Now Backup.."
    automv "${target}" "${target}.bak"
    echo ""
  fi

  mv -v "${file}" "${target}"
}

autorestore() {
  local file="${1}"
  local target="${file}.bak"

  if [ -e "${file}" ]; then
    rm -rv "${file}"
  fi
  mv -v  "${target}" "${file}"

  local lookupTarget="${target}.bak"
  if [ -e "${lookupTarget}" ]; then
    autorestore "${target}"
  fi
}

#== Message ====================================================================
lepton_error_message() {
  >&2 echo "FAILED: ${@}"
  exit 1
}

lepton_ok_message() {
  local SIZE=50
  local FILLED=""
  for ((i=0; i<=$(("${SIZE}" - 2)); i++)); do
    FILLED+="."
  done
  FILLED+="OK"

  local message="${@}"
  echo "${message}${FILLED:${#message}}"
}

#== Multiselct =================================================================
# https://stackoverflow.com/questions/45382472/bash-select-multiple-answers-at-once/54261882
multiselect() {
  echo 'Select with <space>, Done with <enter>!!!'

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
  ~/.mozilla/firefox
  ~/.var/app/org.mozilla.firefox/.mozilla/firefox
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
  local infoFile="profiles.ini"

  for profileDir in "${firefoxProfileDirPaths[@]}"; do
    if [ ! -f "${profileDir}/${PROFILEINFOFILE}" ]; then
      lepton_error_message "Unable to find ${PROFILEINFOFILE} at ${profileDir}"
    fi
  done

  lepton_ok_message "Profiles info file found"
}

#== Profile PATH ===============================================================
firefoxProfilePaths=()
select_profile() {
  local profileName="$1"

  for profileDir in "${firefoxProfileDirPaths[@]}"; do
    local escapeDir=$(echo "${profileDir}" | sed "s|\/|\\\/|g")
    firefoxProfilePaths+=($(
      grep -E "^Path" "${profileDir}/${PROFILEINFOFILE}" |
      cut -f 2 -d"="                                     |
      sed "s/^/${escapeDir}\//"
    ))
  done

  if [ "${profileName}" != "" ]; then
    local targetPath=""
    for profilePath in "${firefoxProfilePaths[@]}"; do
      if [ profilePath == *"${profileName}"* ]; then
        targetPath="${profilePath}"
        break
      fi
    done

    if [ "${targetPath}" == "" ]; then
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
      local targetPaths=()
      local multiPaths=$(echo "${firefoxProfilePaths[@]}" | sed 's/ /;/g')
      multiselect profileSelected "${multiPaths}"
      for ((i=0; i<"${#profileSelected[@]}"; i++)); do
        local result="${profileSelected[${i}]}"
        if [ "$result" == "true" ]; then
          targetPaths+=("${firefoxProfilePaths[${i}]}")
        fi
      done

      firefoxProfilePaths=("${targetPaths[@]}")
      lepton_ok_message "Multi selected profiles"
    fi
  fi
}

#** Install ********************************************************************
#== Install Types ==============================================================
leptonBranch="master"
select_distribution() {
  select distribution in "Original(default)" "Photon-Style"; do
    case "${distribution}" in
      "Original")     leptonBranch="master"       ;;
      "Photon-Style") leptonBranch="photon-style" ;;
    esac
    lepton_ok_message "Selected ${distribution}"
    break
  done
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

#== Each Install ===============================================================
install_local() {
  for profilePath in "${firefoxProfilePaths}"; do
    autocopy user.js         "${profilePath}/user.js"
    autocopy "${currentDir}" "${profilePath}/chrome"
  done
  lepton_ok_message "End profile copy"
}

install_release() {
  for profilePath in "${firefoxProfilePaths}"; do
    autocopy user.js "${profilePath}/user.js"
    autocopy chrome  "${profilePath}/chrome"
  done
  lepton_ok_message "End profile copy"
}

install_network() {
  local duplicate=""
  if [ -e "chrome" ]; then
    duplicate="true"
    automv chrome chrome.bak
  fi

  local isProfile=""
  git clone -b "${}" https://github.com/black7375/Firefox-UI-Fix.git chrome
  for profilePath in "${firefoxProfilePaths}"; do
    autocopy chrome/user.js "${profilePath}/user.js"
    autocopy chrome         "${profilePath}/chrome"

    if [ "${currentDir}" == "${profilePath}" ]; then
      isProfile="true"
    fi
  done
  lepton_ok_message "End profile copy"

  cd "${currentDir}"
  if [ ! "${duplicate}" == "true" ]; then
    rm -rv chrome
  fi
  if [ "${duplicate}" == "true" ]; then
    autorestore chrome
  fi
  lepton_ok_message "End clean files"
}

firefoxProfilePaths=()
install_profile() {
  lepton_ok_message "Started install"

  case "${leptonInstallType}" in
    "Local")   install_local   ;;
    "Release") install_release ;;
    "Network") install_network ;;
  esac

  lepton_ok_message "End install"
}

#** Main ***********************************************************************
install_lepton() {
  local profileDir=""
  local profileName=""

  # Get options.
  while getopts 'f:p:g:t:h' flag; do
    case "${flag}" in
      f) profileDir="${OPTARG}"  ;;
      p) profileName="${OPTARG}" ;;
      h)
        echo "Lepton Theme Install Script:"
        echo "  -f <firefox_folder_path>. Set custom Firefox folder path."
        echo "  -p <profile_name>. Set custom profile name."
        echo "  -h to show this message."
        exit 0
        ;;
    esac
  done

  check_install_types

  check_profile_dir "${profileDir}"
  check_profile_ini
  select_profile "${profileName}"

  install_profile
}

install_lepton "$@"
