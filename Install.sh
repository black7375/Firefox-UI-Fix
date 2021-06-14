#!/usr/bin/env bash
# shellcheck disable=SC2185
function copychrome(){
  \cp -f userChrome.css ~/.mozilla/firefox/"$1"/chrome/userChrome.css
  \cp -f userContent.css ~/.mozilla/firefox/"$1"/chrome/userContent.css
  \cp -f -r icons ~/.mozilla/firefox/"$1"/chrome/
}
function backupchrome(){
  if [ -f ~/.mozilla/firefox/$1/chrome/userChrome.css ];then
    \mv -f ~/.mozilla/firefox/"$1"/chrome/userChrome.css ~/.mozilla/firefox/"$1"/chrome/userChrome.css.bak
    \mv -f ~/.mozilla/firefox/"$1"/chrome/userContent.css ~/.mozilla/firefox/"$1"/chrome/userContent.css.bak
  fi
  cd ~/.mozilla/firefox/"$1"/chrome/icons || exit
  if [ -f ~/.mozilla/firefox/$1/chrome/icons/bug.svg ];then
    for file in *
    do
      \mv -f "$file" "${file/.svg/.svg.bak}"
    done
  fi
  cd "$wherewasi" || exit
}
function backupjs(){
  \mv -f ~/.mozilla/firefox/"$1"/user.js ~/.mozilla/firefox/"$1"/user.js.bak
}
function copyjs(){
  \cp -f user.js ~/.mozilla/firefox/"$1"/user.js
}
function doneinstall()
{
  echo "Installation finished."
}
function install_lepton(){
if [ -f ~/.mozilla/firefox/$1/user.js ]; then
    printf "user.js exists. Do you want to make a backup of it?(Y/n): "
    read -r
    case $REPLY in
      [Nn]* ) printf "Overwriting...\n";copyjs "$1";;
      * )printf "Making a backup...\n";backupjs "$1";copyjs "$1";;
    esac
else
    copyjs "$1"
fi
if [ -d "$HOME/.mozilla/firefox/$1/chrome" ]; then
  printf "The directory chrome/ exists. Do you want to make a backup of it?(Y/n): "
  read -r
  case $REPLY in
      [Nn]* ) printf "Overwriting...\n";copychrome "$1";doneinstall;;
      * )printf "Making a backup...\n";backupchrome "$1";copychrome "$1";doneinstall;;
  esac
else
  mkdir ~/.mozilla/firefox/"$1"/chrome/
  copychrome "$1"
  doneinstall
fi
}

function multipleinstall(){
  echo "You have more than 1 profile for your install. What will you use? Pick a number."
  grep "$1" ~/.mozilla/firefox/profiles.ini | grep 'Default=' | cut -f 2 -d'=' > .installs
  cat --number .installs
  read -r
  profiledir="$(head -"${REPLY}" .installs | tail +"${REPLY}")"
  install_lepton "$profiledir"
  rm -rf .installs
}

function install_option(){
  if [ "$(grep -c "$1" ~/.mozilla/firefox/.folders)" == "1" ]; then
    profiledir="$(grep "$1" ~/.mozilla/firefox/profiles.ini | grep 'Default=' | cut -f 2 -d'=')"
    install_lepton "$profiledir"
  else
    multipleinstall "$1"
  fi
  rm -rf ~/.mozilla/firefox/.folders
}
wherewasi="$(pwd)"
cd ~/.mozilla/firefox/ || exit
find -maxdepth 1 | cut -f 2 -d"/" | sed -n '1!p' > .folders
cd "$wherewasi" || exit
if [ "$(grep -c "Default=" ~/.mozilla/firefox/installs.ini)" == "1" ]; then
  #I have no idea how to sort this out. You fix it please.
  if [ "$(grep -c ".dev-edition-default" ~/.mozilla/firefox/.folders)" == "1" ] && [ "$(grep -c ".dev-edition-default" ~/.mozilla/firefox/.folders)" -gt "1" ]; then
    install_option .dev-edition-default
  elif [ "$(grep -c ".default-release" ~/.mozilla/firefox/.folders)" == "1" ] && [ "$(grep -c ".default-release" ~/.mozilla/firefox/.folders)" -gt "1" ]; then
    install_option .default-release
  elif [ "$(grep -c ".default-nightly" ~/.mozilla/firefox/.folders)" == "1" ] && [ "$(grep -c ".default-nightly" ~/.mozilla/firefox/.folders)" -gt "1" ]; then
    install_option .default-nightly
  elif [ "$(grep -c ".default-esr" ~/.mozilla/firefox/.folders)" == "1" ] && [ "$(grep -c ".default-esr" ~/.mozilla/firefox/.folders)" == "1" ]; then
    install_option .default-esr
  else
    echo "No Firefox profile found."
    exit
  fi
else
  printf "Will you install for ESR, Default, Dev, Nightly?(ESR/Default/Dev/Nightly): "
  read -r
  case $REPLY in
    [Ee][Ss][Rr]) install_option .default-esr;;
    [Dd][Ee][Ff][Aa][Uu][Ll][Tt]) install_option .default-release;;
    [Dd][Ee][Vv]) install_option .dev-edition-default;;
    [Nn][Ii][Gg][Hh][Tt][Ll][Yy]) install_option .default-nightly;;
    *) echo "Unspecified.";exit;;
  esac
fi
