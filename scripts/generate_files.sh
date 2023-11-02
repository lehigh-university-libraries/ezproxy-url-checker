#!/usr/bin/env bash

if [ "$#" -eq 0 ] || [ ! -d $1 ]; then
  echo "Need to pass the directory to EZProxy config to this script"
  exit 1
fi

DIR=$1
if [ ! -f "$DIR/config.txt" ]; then
  echo "$DIR/config.txt doesn't exist"
  exit 1
fi

FILES=("config.txt")
FILES+=($(grep IncludeFile $DIR/config.txt | awk '{print $2}'))

script_dir=$(dirname "$(readlink -f "$0")")
CONFIG_DIR="$script_dir/../config"
echo $CONFIG_DIR
rm -f $CONFIG_DIR/*.txt

for FILE in "${FILES[@]}"; do
  echo "$DIR/$FILE"

  egrep -i '^(U|URL) ' "$DIR/$FILE" \
    | awk '{print $2}' \
    | sort | uniq >> $CONFIG_DIR/urls.txt

  egrep -i '^(H|Host|HJ|HostJavascript) ' "$DIR/$FILE" \
    | awk '{print $2}' \
    | sort | uniq >> $CONFIG_DIR/hosts.txt

  egrep -i '^(Domain|D|DJ|DomainJavascript) '  "$DIR/$FILE" \
    | awk '{print $2}' \
    | sort | uniq >> $CONFIG_DIR/domains.txt
done

RESULTS=( urls.txt hosts.txt domains.txt )
for RESULT in "${RESULTS[@]}"; do
  cat $CONFIG_DIR/$RESULT | sed -E 's#^(https?://)?([^/]+).*#\2#' | sort | uniq > tmp
  mv tmp $CONFIG_DIR/$RESULT
done
