#!/usr/bin/env bash
#Shell scripts in general should not use functions too much since they could slow down the code greatly.
#What I mean my that is write spagetti shell scripts
#TODO(by black7375)
#However, there may be existing user's settings, so back up and make a copy.
#I just made a simple one yesterday, assuming that there may be multiple backup states.
#I think it's better to do a redirection(>>) after backup to merge the contents of the file.
printf "Are you using ESR, Default, or Dev?(ESR/Default/Dev): "
read
if [ "ESR" == "$REPLY" ] || [ "$REPLY" == "esr" ]; then
  profiledir="$(grep '.default-esr' ~/.mozilla/firefox/profiles.ini | grep 'Default=' | cut -f 2 -d'=')"
elif [ "Default" == "$REPLY" ] || [ "default" == "$REPLY" ]; then
  profiledir="$(grep '.default-release' ~/.mozilla/firefox/profiles.ini | grep 'Default=' | cut -f 2 -d'=')"
elif [ "Dev" == "$REPLY" ] || [ "dev" == "$REPLY" ]; then
  profiledir="$(grep '.dev-edition-default' ~/.mozilla/firefox/profiles.ini | grep 'Default=' | cut -f 2 -d'=')"
else
  echo "Unspecified."
  exit
printf "Do you want to disable everything being selected when you click at the URL bar?(N/y): "
read
if [ "y" == "$REPLY" ] || [ "Y" == "$REPLY" ]; then
  curl -s -L https://raw.githubusercontent.com/7k5x/firefox-selection-fix/master/fixfx-selection.sh | bash
else
  printf "\nSkipiing.\n"
if [[ -f ~/.mozilla/Firefox/${profiledir}/user.js ]]
then
    printf "user.js exists. Do you want to make a backup of it?(Y/n): "
    read
    if [ "N" == "$REPLY" ] || [ "n" == "$REPLY" ]; then
      printf"Overwriting...\n"
      rm -rf ~/.mozilla/Firefox/${profiledir}/user.js
      cp user.js ~/.mozilla/Firefox/${profiledir}
    else
      printf "Making a backup...\n"
      if [[ -d "~/.mozilla/Firefox/${profiledir}/backup" ]]
      then
        rm -rf ~/.mozilla/Firefox/${profiledir}/backup
      fi
      mkdir ~/.mozilla/Firefox/${profiledir}/backup
      mv ~/.mozilla/Firefox/${profiledir}/user.js ~/.mozilla/Firefox/${profiledir}/backup
      cp user.js ~/.mozilla/Firefox/${profiledir}
      
fi
cp user.js ~/.mozilla/Firefox/${profiledir}
if [[ -d "~/.mozilla/Firefox/${profiledir}/chrome" ]]
then
  printf "user.js exists. Do you want to make a backup of it?(Y/n): "
    read
    if [ "N" == "$REPLY" ] || [ "n" == "$REPLY" ]; then
      printf"Overwriting...\n"
      rm -rf ~/.mozilla/Firefox/${profiledir}/user.js
      cp user.js ~/.mozilla/Firefox/${profiledir}
    else
      printf "Making a backup...\n"
      if [[ -d "~/.mozilla/Firefox/${profiledir}/backup" ]]
      then
        rm -rf ~/.mozilla/Firefox/${profiledir}/backup
      fi
      mkdir ~/.mozilla/Firefox/${profiledir}/backup
      mv ~/.mozilla/Firefox/${profiledir}/user.js ~/.mozilla/Firefox/${profiledir}/backup
      cp user.js ~/.mozilla/Firefox/${profiledir}
      
fi
mkdir ~/.mozilla/Firefox/${profiledir}/chrome
cp userChrome.css ~/.mozilla/Firefox/${profiledir}/chrome
cp userContent.css ~/.mozilla/Firefox/${profiledir}/chrome
cp -r icon ~/.mozilla/Firefox/${profiledir}/chrome
