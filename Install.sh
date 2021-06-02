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
  echo "What did you say?"
  break
