autocopy() {
  local file=${1}
  local target=${2}

  if [ -e "${target}" ]; then
    echo "${target} alreay exist."
    echo "Now Backup.."
    autocopy "${target}" "${target}.bak"
    echo""
  fi

  cp -v "${file}" "${target}"
}

install_lepton() {
  local userConfig="user.js"
  autocopy "${userConfig}" "../${userConfig}"
}
install_lepton
