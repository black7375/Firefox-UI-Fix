#!/usr/bin/env bash
#TODO(by black7375)
#However, there may be existing user's settings, so back up and make a copy.
#I just made a simple one yesterday, assuming that there may be multiple backup states.
#I think it's better to do a redirection(>>) after backup to merge the contents of the file.
printf "Are you using ESR, Default, or Dev?(ESR/Default/Dev): "
read -r
if [ "ESR" == "$REPLY" ] || [ "$REPLY" == "esr" ]; then
  profiledir="$(grep '.default-esr' ~/.mozilla/firefox/profiles.ini | grep 'Default=' | cut -f 2 -d'=')"
elif [ "Default" == "$REPLY" ] || [ "default" == "$REPLY" ]; then
  profiledir="$(grep '.default-release' ~/.mozilla/firefox/profiles.ini | grep 'Default=' | cut -f 2 -d'=')"
elif [ "Dev" == "$REPLY" ] || [ "dev" == "$REPLY" ]; then
  profiledir="$(grep '.dev-edition-default' ~/.mozilla/firefox/profiles.ini | grep 'Default=' | cut -f 2 -d'=')"
else
  echo "Unspecified."
  exit
fi
if [[ -f ~/.mozilla/Firefox/${profiledir}/user.js ]]; then
    printf "user.js exists. Do you want to make a backup of it?(Y/n): "
    read -r
    if [ "N" == "$REPLY" ] || [ "n" == "$REPLY" ]; then
      printf"Overwriting...\n"
      rm -rf ~/.mozilla/Firefox/"${profiledir}"/user.js
      cp user.js ~/.mozilla/Firefox/"${profiledir}"
    else
      printf "Making a backup...\n"
      if [[ -d "$HOME/.mozilla/Firefox/${profiledir}/backup" ]]; then
        rm -rf ~/.mozilla/Firefox/"${profiledir}"/backup
      fi
    fi
    else
      cp user.js ~/.mozilla/Firefox/"${profiledir}"
fi
if [[ -d "$HOME/.mozilla/Firefox/${profiledir}/chrome" ]]; then
  printf "The directory chrome/ exists. Do you want to make a backup of it?(Y/n): "
  read -r
  if [ "N" == "$REPLY" ] || [ "n" == "$REPLY" ]; then
    printf"Overwriting...\n"
    rm -rf ~/.mozilla/Firefox/"${profiledir}"/chrome
    mkdir ~/.mozilla/Firefox/"${profiledir}"/chrome
    cp userChrome.css ~/.mozilla/Firefox/"${profiledir}"/chrome
    cp userContent.css ~/.mozilla/Firefox/"${profiledir}"/chrome
    cp -r icon ~/.mozilla/Firefox/"${profiledir}"/chrome
  else
    printf "Making a backup...\n"
    if [[ -d "$HOME/.mozilla/Firefox/${profiledir}/backup/chrome" ]]; then
      rm -rf ~/.mozilla/Firefox/"${profiledir}"/backup/chrome
    fi
    mkdir ~/.mozilla/Firefox/"${profiledir}"/backup/chrome
    mv ~/.mozilla/Firefox/"${profiledir}"/chrome ~/.mozilla/Firefox/"${profiledir}"/backup
    cp userChrome.css ~/.mozilla/Firefox/"${profiledir}"/chrome
    cp userContent.css ~/.mozilla/Firefox/"${profiledir}"/chrome
    cp -r icon ~/.mozilla/Firefox/"${profiledir}"/chrome
  fi
  else
    mkdir ~/.mozilla/Firefox/"${profiledir}"/chrome
    cp userChrome.css ~/.mozilla/Firefox/"${profiledir}"/chrome
    cp userContent.css ~/.mozilla/Firefox/"${profiledir}"/chrome
    cp -r icon ~/.mozilla/Firefox/"${profiledir}"/chrome
fi
printf "\nInstallation finished."
