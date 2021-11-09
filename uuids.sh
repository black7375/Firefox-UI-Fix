#!/bin/bash

## Mac
## arg1 - required:
##     add: add UUIDs found in internal_UUID.txt to corresponding .css files
##     remove: add UUIDs found in internal_UUID.txt to corresponding .css files
## arg2 - optional:
##     nogen: don't generate internal_UUIDs.txt before adding/removing
## designed for users using userContent_imports.css
## entries in internal_UUIDs.txt should take on the following format:  webextension_id=internal_UUID
## author: @overdodactyl
## version: 1.0

# Original: "scripts/internal_UUIDs.txt"
UUID_FILE="internal_UUIDs.txt"

method=$1
uuid_finder=${2:-gen}

# Determine whether UUIDs will be inserted or removed
if [ $method = "add" ]; then
  var1=0
  var2=1
  var3="inserted"
elif [ $method = "remove" ]; then
  var1=1
  var2=0
  var3="removed"
else
  echo "must pass argument add or remove"
  exit 1
fi

currdir=$(pwd)
sfp=$(readlink -f "${BASH_SOURCE[0]}" 2>/dev/null || greadlink -f "${BASH_SOURCE[0]}" 2>/dev/null)
if [ -z "$sfp" ]; then sfp=${BASH_SOURCE[0]}; fi
cd "$(dirname "${sfp}")" && cd ..

if [ $uuid_finder != "nogen" ]; then
  ## Generate internal_UUIDs.txt
  touch "${UUID_FILE}"

  ## Get installed extesnsions from prefs.js
  line=$(sed -n -e 's/^user_pref("extensions.webextensions.uuids", "{\(.*\).*}");/\1/p' ./../prefs.js)

  ## Clear internal_UUIDS.txt
  > "${UUID_FILE}"

  ## Write to internal_UUIDs
  IFS=',' read -ra EXTS <<< "$line"
  for i in "${EXTS[@]}"; do
    id=$(echo $i | sed -n 's/.*"\(.*\)\\":.*/\1/p')
    uuid=$(echo $i | sed -n 's/.*"\(.*\)\\".*/\1/p')
    echo "$id=$uuid" >> "${UUID_FILE}"
  done
  echo "${UUID_FILE} was created"
fi


## Insert/remove any UUIDs defined in internal_UUIDs.txt into userContent.css
while IFS='' read -r line || [[ -n "$line" ]]; do
    IFS='=' read -r -a array <<< "$line"
    webextension_name=${array[0]%_UUID}
    for filename in css/userContent-files/webextension-tweaks/*.css; do
      sed -i '' "s/${array[$var1]}/${array[$var2]}/" "${filename}"
      ##echo ${filename}
    done
    sed -i '' "s/${array[$var1]}/${array[$var2]}/" "userContent.css"
done < "scripts/internal_UUIDs.txt"
echo "UUIDs were ${var3}"
